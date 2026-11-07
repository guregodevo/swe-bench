# Survey: MultiValueField ignores a required value of a sub field

Paths named or shown by the issue first, then the code they reach, then siblings that do the same thing the same way.

- `django/forms/fields.py:MultiValueField.clean` — the behaviour happens here: when every submitted sub-value is empty it returns `self.compress([])` early (line 1029) without ever consulting the individual `field.required` flags, so a required sub-field is never reported.
- `django/forms/fields.py:MultiValueField.__init__` — with `require_all_fields=False` it leaves each sub-field's `required` flag intact (only forcing `required = False` when `require_all_fields` is true), which is what makes the ignored flag meaningful.
- `django/forms/fields.py:MultiValueField.validate` — a no-op override, so the base `Field.validate` required check is deliberately skipped and all required handling is left to `clean`.
- `django/forms/fields.py:MultiValueField.compress` — abstract hook called by `clean` with `[]` on the all-empty path, so the subclass (the issue's `MF.compress`) receives an empty list and returns `[]` instead of an error.
- `django/forms/fields.py:MultiValueField.has_changed` — compares each sub-field's initial/data pair, the other place that walks `self.fields` per sub-value.
- `django/forms/fields.py:Field.clean` — the base single-value path that calls `to_python`, `validate` and `run_validators`; the required check that `MultiValueField` bypasses lives in `Field.validate`.
- `django/forms/fields.py:Field.validate` — raises the `required` error for an empty value when `self.required` is true, the check the all-empty early return skips for sub-fields.
- `django/forms/fields.py:CharField` — the sub-field class used in the issue; its `required=True` is the flag that is ignored.
- `django/forms/widgets.py:MultiWidget.value_from_datadict` — produces the list of per-subwidget values (`['', '']` in the issue) that `MultiValueField.clean` receives.
- `django/forms/widgets.py:MultiWidget.decompress` — abstract companion to `compress`, used by `has_changed` and disabled-field handling to turn a compressed value back into a list.
- `django/forms/forms.py:Form.is_valid` — the public API the issue calls; returns `self.is_bound and not self.errors`, so it reports `True` because `clean` produced no error.
- `django/forms/forms.py:Form.errors` — triggers `full_clean()` on first access, the entry point into field cleaning.
- `django/forms/forms.py:Form.full_clean` — runs `_clean_fields`/`_clean_form`/`_post_clean` and populates `_errors`.
- `django/forms/forms.py:Form._clean_fields` — calls `field.clean(value)` for each bound field and records any `ValidationError`; the `MultiValueField` result flows through here.
- `django/forms/boundfield.py:BoundField.data` — fetches the widget's data for the field via `_widget_data_value`, feeding the list into `clean`.
- `django/forms/boundfield.py:BoundField.value` — applies `bound_data`/`prepare_value` for rendering, the other consumer of the multi-value data.

## Siblings that do the same thing the same way

- `django/forms/fields.py:SplitDateTimeField.compress` — a `MultiValueField` subclass that re-checks its own sub-values for emptiness and raises `invalid_date`/`invalid_time`, the workaround the base `clean` does not do for required sub-fields.
- `django/forms/fields.py:SplitDateTimeField.__init__` — builds the two sub-fields and delegates to `MultiValueField.__init__`, inheriting the same required-handling behaviour.
- `django/contrib/postgres/forms/ranges.py:BaseRangeField.__init__` — a `MultiValueField` subclass that sets `require_all_fields=False` and makes both sub-fields `required=False`, the parallel configuration to the issue's field.
- `django/contrib/postgres/forms/ranges.py:BaseRangeField.compress` — returns `None` for an empty list, the same all-empty short-circuit pattern as the issue's `compress`.
- `django/contrib/postgres/forms/ranges.py:RangeWidget.decompress` — the `MultiWidget` sibling that turns a range into `(lower, upper)` for the same multi-value pipeline.
- `django/forms/fields.py:ComboField.clean` — a parallel multi-field aggregator that also forces sub-fields to `required=False` and delegates required handling to the container.
- `django/forms/fields.py:ComboField.__init__` — the same "set sub-field required False, validate at the container level" pattern as `MultiValueField.__init__`.
- `django/forms/formsets.py:BaseFormSet.is_valid` — the collection-level analogue of `Form.is_valid`, aggregating per-form validity the same way.
- `django/forms/formsets.py:BaseFormSet.full_clean` — the collection-level analogue of `Form.full_clean`, the other place form errors are gathered.
