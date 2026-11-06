# django__django-14725 — memdoor single call

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 179s 203 lines cost=0.010811 in=708963 cached=600576 out=15060 calls=37`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `do` (agent)

**user**

```
Workflow single, task do.

Provide a way for model formsets to disallow new object creation
Description
	
Model formsets don't provide a way to create an "edit only" view of objects. We see users trying to use extra=0 to accomplish this, but that's not reliable as extra is merely meant for the extra number of forms to display. You can add more forms with Javascript (or just send additional post data).

This task is done when this command exits 0 in the project: test -n "$(git status --porcelain -- . ':(exclude).memdoor')"
Make that true.
```

**assistant → tool `bash`**

```json
{
  "command": "pwd && ls && git status --porcelain && git log --oneline -5"
}
```

**tool result**

```
/testbed
AUTHORS
CONTRIBUTING.rst
Django.egg-info
Gruntfile.js
INSTALL
LICENSE
LICENSE.python
MANIFEST.in
README.rst
django
docs
extras
js_tests
package.json
pyproject.toml
scripts
setup.cfg
setup.py
tests
tox.ini
?? .memdoor/
cba5ce872e SWE-bench
0af9a5fc7d Fixed #33463 -- Fixed QuerySet.bulk_update() with F() expressions.
e972620ada Fixed #33462 -- Fixed migration crash when altering type of primary key with MTI and foreign key.
2eed554c3f Fixed wrapping of long messages in the admin.
d15a10afb5 Adjusted CBV resolver_match example in testing tools docs.
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"class BaseModelFormSet\\|def save_existing_objects\\|def save_new_objects\\|def _existing_object\\|modelformset_factory\\|def save(\" django/forms/models.py | head -50 && grep -n \"class BaseModelFormSet\\|def save_existing_objects\\|def save_new_objects\\|modelformset_factory\\|def _construct_form\" django/forms/formsets.py"
}
```

**tool result**

```
23:    'BaseModelFormSet', 'modelformset_factory', 'BaseInlineFormSet',
451:    def save(self, commit=True):
566:class BaseModelFormSet(BaseFormSet):
587:    def _existing_object(self, pk):
667:    def save(self, commit=True):
788:    def save_existing_objects(self, commit=True):
814:    def save_new_objects(self, commit=True):
872:def modelformset_factory(model, form=ModelForm, formfield_callback=None,
884:            "Calling modelformset_factory without defining 'fields' or "
1113:    FormSet = modelformset_factory(model, **kwargs)
188:    def _construct_form(self, i, **kwargs):
```

**assistant → tool `read_file`**

```json
{
  "path": "django/forms/models.py",
  "offset": 560,
  "limit": 380
}
```

**tool result**

```
    # Instantiate type(form) in order to use the same metaclass as form.
    return type(form)(class_name, (form,), form_class_attrs)


# ModelFormSets ##############################################################

class BaseModelFormSet(BaseFormSet):
    """
    A ``FormSet`` for editing a queryset and/or adding new objects to it.
    """
    model = None

    # Set of fields that must be unique among forms of this set.
    unique_fields = set()

    def __init__(self, data=None, files=None, auto_id='id_%s', prefix=None,
                 queryset=None, *, initial=None, **kwargs):
        self.queryset = queryset
        self.initial_extra = initial
        super().__init__(**{'data': data, 'files': files, 'auto_id': auto_id, 'prefix': prefix, **kwargs})

    def initial_form_count(self):
        """Return the number of forms that are required in this FormSet."""
        if not self.is_bound:
            return len(self.get_queryset())
        return super().initial_form_count()

    def _existing_object(self, pk):
        if not hasattr(self, '_object_dict'):
            self._object_dict = {o.pk: o for o in self.get_queryset()}
        return self._object_dict.get(pk)

    def _get_to_python(self, field):
        """
        If the field is a related field, fetch the concrete field's (that
        is, the ultimate pointed-to field's) to_python.
        """
        while field.remote_field is not None:
            field = field.remote_field.get_related_field()
        return field.to_python

    def _construct_form(self, i, **kwargs):
        pk_required = i < self.initial_form_count()
        if pk_required:
            if self.is_bound:
                pk_key = '%s-%s' % (self.add_prefix(i), self.model._meta.pk.name)
                try:
                    pk = self.data[pk_key]
                except KeyError:
                    # The primary key is missing. The user may have tampered
                    # with POST data.
                    pass
                else:
                    to_python = self._get_to_python(self.model._meta.pk)
                    try:
                        pk = to_python(pk)
                    except ValidationError:
                        # The primary key exists but is an invalid value. The
                        # user may have tampered with POST data.
                        pass
                    else:
                        kwargs['instance'] = self._existing_object(pk)
            else:
                kwargs['instance'] = self.get_queryset()[i]
        elif self.initial_extra:
            # Set initial values for extra forms
            try:
                kwargs['initial'] = self.initial_extra[i - self.initial_form_count()]
            except IndexError:
                pass
        form = super()._construct_form(i, **kwargs)
        if pk_required:
            form.fields[self.model._meta.pk.name].required = True
        return form

    def get_queryset(self):
        if not hasattr(self, '_queryset'):
            if self.queryset is not None:
                qs = self.queryset
            else:
                qs = self.model._default_manager.get_queryset()

            # If the queryset isn't already ordered we need to add an
            # artificial ordering here to make sure that all formsets
            # constructed from this queryset have the same form order.
            if not qs.ordered:
                qs = qs.order_by(self.model._meta.pk.name)

            # Removed queryset limiting here. As per discussion re: #13023
            # on django-dev, max_num should not prevent existing
            # related objects/inlines from being displayed.
            self._queryset = qs
        return self._queryset

    def save_new(self, form, commit=True):
        """Save and return a new model instance for the given form."""
        return form.save(commit=commit)

    def save_existing(self, form, instance, commit=True):
        """Save and return an existing model instance for the given form."""
        return form.save(commit=commit)

    def delete_existing(self, obj, commit=True):
        """Deletes an existing model instance."""
        if commit:
            obj.delete()

    def save(self, commit=True):
        """
        Save model instances for every form, adding and changing instances
        as necessary, and return the list of instances.
        """
        if not commit:
            self.saved_forms = []

            def save_m2m():
                for form in self.saved_forms:
                    form.save_m2m()
            self.save_m2m = save_m2m
        return self.save_existing_objects(commit) + self.save_new_objects(commit)

    save.alters_data = True

    def clean(self):
        self.validate_unique()

    def validate_unique(self):
        # Collect unique_checks and date_checks to run from all the forms.
        all_unique_checks = set()
        all_date_checks = set()
        forms_to_delete = self.deleted_forms
        valid_forms = [form for form in self.forms if form.is_valid() and form not in forms_to_delete]
        for form in valid_forms:
            exclude = form._get_validation_exclusions()
            unique_checks, date_checks = form.instance._get_unique_checks(exclude=exclude)
            all_unique_checks.update(unique_checks)
            all_date_checks.update(date_checks)

        errors = []
        # Do each of the unique checks (unique and unique_together)
        for uclass, unique_check in all_unique_checks:
            seen_data = set()
            for form in valid_forms:
                # Get the data for the set of fields that must be unique among the forms.
                row_data = (
                    field if field in self.unique_fields else form.cleaned_data[field]
                    for field in unique_check if field in form.cleaned_data
                )
                # Reduce Model instances to their primary key values
                row_data = tuple(
                    d._get_pk_val() if hasattr(d, '_get_pk_val')
                    # Prevent "unhashable type: list" errors later on.
                    else tuple(d) if isinstance(d, list)
                    else d for d in row_data
                )
                if row_data and None not in row_data:
                    # if we've already seen it then we have a uniqueness failure
                    if row_data in seen_data:
                        # poke error messages into the right places and mark
                        # the form as invalid
                        errors.append(self.get_unique_error_message(unique_check))
                        form._errors[NON_FIELD_ERRORS] = self.error_class(
                            [self.get_form_error()],
                            renderer=self.renderer,
                        )
                        # remove the data from the cleaned_data dict since it was invalid
                        for field in unique_check:
                            if field in form.cleaned_data:
                                del form.cleaned_data[field]
                    # mark the data as seen
                    seen_data.add(row_data)
        # iterate over each of the date checks now
        for date_check in all_date_checks:
            seen_data = set()
            uclass, lookup, field, unique_for = date_check
            for form in valid_forms:
                # see if we have data for both fields
                if (form.cleaned_data and form.cleaned_data[field] is not None and
                        form.cleaned_data[unique_for] is not None):
                    # if it's a date lookup we need to get the data for all the fields
                    if lookup == 'date':
                        date = form.cleaned_data[unique_for]
                        date_data = (date.year, date.month, date.day)
                    # otherwise it's just the attribute on the date/datetime
                    # object
                    else:
                        date_data = (getattr(form.cleaned_data[unique_for], lookup),)
                    data = (form.cleaned_data[field],) + date_data
                    # if we've already seen it then we have a uniqueness failure
                    if data in seen_data:
                        # poke error messages into the right places and mark
                        # the form as invalid
                        errors.append(self.get_date_error_message(date_check))
                        form._errors[NON_FIELD_ERRORS] = self.error_class(
                            [self.get_form_error()],
                            renderer=self.renderer,
                        )
                        # remove the data from the cleaned_data dict since it was invalid
                        del form.cleaned_data[field]
                    # mark the data as seen
                    seen_data.add(data)

        if errors:
            raise ValidationError(errors)

    def get_unique_error_message(self, unique_check):
        if len(unique_check) == 1:
            return gettext("Please correct the duplicate data for %(field)s.") % {
                "field": unique_check[0],
            }
        else:
            return gettext("Please correct the duplicate data for %(field)s, which must be unique.") % {
                "field": get_text_list(unique_check, _("and")),
            }

    def get_date_error_message(self, date_check):
        return gettext(
            "Please correct the duplicate data for %(field_name)s "
            "which must be unique for the %(lookup)s in %(date_field)s."
        ) % {
            'field_name': date_check[2],
            'date_field': date_check[3],
            'lookup': str(date_check[1]),
        }

    def get_form_error(self):
        return gettext("Please correct the duplicate values below.")

    def save_existing_objects(self, commit=True):
        self.changed_objects = []
        self.deleted_objects = []
        if not self.initial_forms:
            return []

        saved_instances = []
        forms_to_delete = self.deleted_forms
        for form in self.initial_forms:
            obj = form.instance
            # If the pk is None, it means either:
            # 1. The object is an unexpected empty model, created by invalid
            #    POST data such as an object outside the formset's queryset.
            # 2. The object was already deleted from the database.
            if obj.pk is None:
                continue
            if form in forms_to_delete:
                self.deleted_objects.append(obj)
                self.delete_existing(obj, commit=commit)
            elif form.has_changed():
                self.changed_objects.append((obj, form.changed_data))
                saved_instances.append(self.save_existing(form, obj, commit=commit))
                if not commit:
                    self.saved_forms.append(form)
        return saved_instances

    def save_new_objects(self, commit=True):
        self.new_objects = []
        for form in self.extra_forms:
            if not form.has_changed():
                continue
            # If someone has marked an add form for deletion, don't save the
            # object.
            if self.can_delete and self._should_delete_form(form):
                continue
            self.new_objects.append(self.save_new(form, commit=commit))
            if not commit:
                self.saved_forms.append(form)
        return self.new_objects

    def add_fields(self, form, index):
        """Add a hidden field for the object's primary key."""
        from django.db.models import AutoField, ForeignKey, OneToOneField
        self._pk_field = pk = self.model._meta.pk
        # If a pk isn't editable, then it won't be on the form, so we need to
        # add it here so we can tell which object is which when we get the
        # data back. Generally, pk.editable should be false, but for some
        # reason, auto_created pk fields and AutoField's editable attribute is
        # True, so check for that as well.

        def pk_is_not_editable(pk):
            return (
                (not pk.editable) or (pk.auto_created or isinstance(pk, AutoField)) or (
                    pk.remote_field and pk.remote_field.parent_link and
                    pk_is_not_editable(pk.remote_field.model._meta.pk)
                )
            )
        if pk_is_not_editable(pk) or pk.name not in form.fields:
            if form.is_bound:
                # If we're adding the related instance, ignore its primary key
                # as it could be an auto-generated default which isn't actually
                # in the database.
                pk_value = None if form.instance._state.adding else form.instance.pk
            else:
                try:
                    if index is not None:
                        pk_value = self.get_queryset()[index].pk
                    else:
                        pk_value = None
                except IndexError:
                    pk_value = None
            if isinstance(pk, (ForeignKey, OneToOneField)):
                qs = pk.remote_field.model._default_manager.get_queryset()
            else:
                qs = self.model._default_manager.get_queryset()
            qs = qs.using(form.instance._state.db)
            if form._meta.widgets:
                widget = form._meta.widgets.get(self._pk_field.name, HiddenInput)
            else:
                widget = HiddenInput
            form.fields[self._pk_field.name] = ModelChoiceField(qs, initial=pk_value, required=False, widget=widget)
        super().add_fields(form, index)


def modelformset_factory(model, form=ModelForm, formfield_callback=None,
                         formset=BaseModelFormSet, extra=1, can_delete=False,
                         can_order=False, max_num=None, fields=None, exclude=None,
                         widgets=None, validate_max=False, localized_fields=None,
                         labels=None, help_texts=None, error_messages=None,
                         min_num=None, validate_min=False, field_classes=None,
                         absolute_max=None, can_delete_extra=True, renderer=None):
    """Return a FormSet class for the given Django model class."""
    meta = getattr(form, 'Meta', None)
    if (getattr(meta, 'fields', fields) is None and
            getattr(meta, 'exclude', exclude) is None):
        raise ImproperlyConfigured(
            "Calling modelformset_factory without defining 'fields' or "
            "'exclude' explicitly is prohibited."
        )

    form = modelform_factory(model, form=form, fields=fields, exclude=exclude,
                             formfield_callback=formfield_callback,
                             widgets=widgets, localized_fields=localized_fields,
                             labels=labels, help_texts=help_texts,
                             error_messages=error_messages, field_classes=field_classes)
    FormSet = formset_factory(form, formset, extra=extra, min_num=min_num, max_num=max_num,
                              can_order=can_order, can_delete=can_delete,
                              validate_min=validate_min, validate_max=validate_max,
                              absolute_max=absolute_max, can_delete_extra=can_delete_extra,
                              renderer=renderer)
    FormSet.model = model
    return FormSet


# InlineFormSets #############################################################

class BaseInlineFormSet(BaseModelFormSet):
    """A formset for child objects related to a parent."""
    def __init__(self, data=None, files=None, instance=None,
                 save_as_new=False, prefix=None, queryset=None, **kwargs):
        if instance is None:
            self.instance = self.fk.remote_field.model()
        else:
            self.instance = instance
        self.save_as_new = save_as_new
        if queryset is None:
            queryset = self.model._default_manager
        if self.instance.pk is not None:
            qs = queryset.filter(**{self.fk.name: self.instance})
        else:
            qs = queryset.none()
        self.unique_fields = {self.fk.name}
        super().__init__(data, files, prefix=prefix, queryset=qs, **kwargs)

        # Add the generated field to form._meta.fields if it's defined to make
        # sure validation isn't skipped on that field.
        if self.form._meta.fields and self.fk.name not in self.form._meta.fields:
            if isinstance(self.form._meta.fields, tuple):
                self.form._meta.fields = list(self.form._meta.fields)
            self.form._meta.fields.append(self.fk.name)

    def initial_form_count(self):
        if self.save_as_new:
            return 0
        return super().initial_form_count()

    def _construct_form(self, i, **kwargs):
        form = super()._construct_form(i, **kwargs)
        if self.save_as_new:
            mutable = getattr(form.data, '_mutable', None)
            # Allow modifying an immutable QueryDict.
            if mutable is not None:

[488 more lines in /testbed/django/forms/models.py (1427 in all). read_file with offset: 940 to continue]
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"edit_only\" . --exclude-dir=.git --exclude-dir=.memdoor | head -20; grep -n \"def formset_factory\" -A60 django/forms/formsets.py | head -100"
}
```

**tool result**

```
478:def formset_factory(form, formset=BaseFormSet, extra=1, can_order=False,
479-                    can_delete=False, max_num=None, validate_max=False,
480-                    min_num=None, validate_min=False, absolute_max=None,
481-                    can_delete_extra=True, renderer=None):
482-    """Return a FormSet for the given form class."""
483-    if min_num is None:
484-        min_num = DEFAULT_MIN_NUM
485-    if max_num is None:
486-        max_num = DEFAULT_MAX_NUM
487-    # absolute_max is a hard limit on forms instantiated, to prevent
488-    # memory-exhaustion attacks. Default to max_num + DEFAULT_MAX_NUM
489-    # (which is 2 * DEFAULT_MAX_NUM if max_num is None in the first place).
490-    if absolute_max is None:
491-        absolute_max = max_num + DEFAULT_MAX_NUM
492-    if max_num > absolute_max:
493-        raise ValueError(
494-            "'absolute_max' must be greater or equal to 'max_num'."
495-        )
496-    attrs = {
497-        'form': form,
498-        'extra': extra,
499-        'can_order': can_order,
500-        'can_delete': can_delete,
501-        'can_delete_extra': can_delete_extra,
502-        'min_num': min_num,
503-        'max_num': max_num,
504-        'absolute_max': absolute_max,
505-        'validate_min': validate_min,
506-        'validate_max': validate_max,
507-        'renderer': renderer or get_default_renderer(),
508-    }
509-    return type(form.__name__ + 'FormSet', (formset,), attrs)
510-
511-
512-def all_valid(formsets):
513-    """Validate every formset and return True if all are valid."""
514-    # List comprehension ensures is_valid() is called for all formsets.
515-    return all([formset.is_valid() for formset in formsets])
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"edit_only\\|save_as_new\\|can_delete_extra\" tests/forms_tests/tests/test_formsets.py | head; grep -n \"modelformset_factory\\|inlineformset_factory\" docs/topics/forms/modelforms.txt | head -40"
}
```

**tool result**

```
1269:    def test_can_delete_extra_formset_forms(self):
1280:            can_delete_extra=False,
760:    >>> from django.forms import modelformset_factory
762:    >>> AuthorFormSet = modelformset_factory(Author, fields=('name', 'title'))
768:    >>> AuthorFormSet = modelformset_factory(Author, exclude=('birth_date',))
786:    :func:`~django.forms.models.modelformset_factory` uses
820:    >>> AuthorFormSet = modelformset_factory(
831:By default, when you use ``modelformset_factory``, a model form will
847:    AuthorFormSet = modelformset_factory(Author, form=AuthorForm)
850:``modelformset_factory`` function has several arguments which are
861:    >>> AuthorFormSet = modelformset_factory(
871:    >>> AuthorFormSet = modelformset_factory(
884::func:`~django.forms.models.modelformset_factory`. However, with model
941:to :func:`~django.forms.models.modelformset_factory` to limit the number of
949:    >>> AuthorFormSet = modelformset_factory(Author, fields=('name',), max_num=1)
963:    >>> AuthorFormSet = modelformset_factory(Author, fields=('name',), max_num=4, extra=2)
981:    from django.forms import modelformset_factory
986:        AuthorFormSet = modelformset_factory(Author, fields=('name', 'title'))
1047:    from django.forms import modelformset_factory
1052:        AuthorFormSet = modelformset_factory(Author, fields=('name', 'title'))
1151:    >>> from django.forms import inlineformset_factory
1152:    >>> BookFormSet = inlineformset_factory(Author, Book, fields=('title',))
1162:    :func:`~django.forms.models.inlineformset_factory` uses
1163:    :func:`~django.forms.models.modelformset_factory` and marks
1194:    >>> from django.forms import inlineformset_factory
1195:    >>> BookFormSet = inlineformset_factory(Author, Book, fields=('title',),
1221::func:`~django.forms.models.inlineformset_factory`::
1223:    >>> FriendshipFormSet = inlineformset_factory(Friend, Friendship, fk_name='from_friend',
1234:        BookInlineFormSet = inlineformset_factory(Author, Book, fields=('title',))
1251:``inlineformset_factory`` uses ``modelformset_factory`` and passes most
1252:of its arguments to ``modelformset_factory``. This means you can use
1254:``modelformset_factory``. See `Specifying widgets to use in the form with
```

**assistant → tool `bash`**

```json
{
  "command": "python - <<'PY'\nimport django, inspect, django.forms.models as m\nprint(django.get_version())\nPY\nfind / -path '*django/forms/models.py' 2>/dev/null | head"
}
```

**tool result**

```
4.1.dev20260813013029
/testbed/django/forms/models.py
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"def inlineformset_factory\" -A80 django/forms/models.py"
}
```

**tool result**

```
1072:def inlineformset_factory(parent_model, model, form=ModelForm,
1073-                          formset=BaseInlineFormSet, fk_name=None,
1074-                          fields=None, exclude=None, extra=3, can_order=False,
1075-                          can_delete=True, max_num=None, formfield_callback=None,
1076-                          widgets=None, validate_max=False, localized_fields=None,
1077-                          labels=None, help_texts=None, error_messages=None,
1078-                          min_num=None, validate_min=False, field_classes=None,
1079-                          absolute_max=None, can_delete_extra=True, renderer=None):
1080-    """
1081-    Return an ``InlineFormSet`` for the given kwargs.
1082-
1083-    ``fk_name`` must be provided if ``model`` has more than one ``ForeignKey``
1084-    to ``parent_model``.
1085-    """
1086-    fk = _get_foreign_key(parent_model, model, fk_name=fk_name)
1087-    # enforce a max_num=1 when the foreign key to the parent model is unique.
1088-    if fk.unique:
1089-        max_num = 1
1090-    kwargs = {
1091-        'form': form,
1092-        'formfield_callback': formfield_callback,
1093-        'formset': formset,
1094-        'extra': extra,
1095-        'can_delete': can_delete,
1096-        'can_order': can_order,
1097-        'fields': fields,
1098-        'exclude': exclude,
1099-        'min_num': min_num,
1100-        'max_num': max_num,
1101-        'widgets': widgets,
1102-        'validate_min': validate_min,
1103-        'validate_max': validate_max,
1104-        'localized_fields': localized_fields,
1105-        'labels': labels,
1106-        'help_texts': help_texts,
1107-        'error_messages': error_messages,
1108-        'field_classes': field_classes,
1109-        'absolute_max': absolute_max,
1110-        'can_delete_extra': can_delete_extra,
1111-        'renderer': renderer,
1112-    }
1113-    FormSet = modelformset_factory(model, **kwargs)
1114-    FormSet.fk = fk
1115-    return FormSet
1116-
1117-
1118-# Fields #####################################################################
1119-
1120-class InlineForeignKeyField(Field):
1121-    """
1122-    A basic integer field that deals with validating the given value to a
1123-    given parent instance in an inline.
1124-    """
1125-    widget = HiddenInput
1126-    default_error_messages = {
1127-        'invalid_choice': _('The inline value did not match the parent instance.'),
1128-    }
1129-
1130-    def __init__(self, parent_instance, *args, pk_field=False, to_field=None, **kwargs):
1131-        self.parent_instance = parent_instance
1132-        self.pk_field = pk_field
1133-        self.to_field = to_field
1134-        if self.parent_instance is not None:
1135-            if self.to_field:
1136-                kwargs["initial"] = getattr(self.parent_instance, self.to_field)
1137-            else:
1138-                kwargs["initial"] = self.parent_instance.pk
1139-        kwargs["required"] = False
1140-        super().__init__(*args, **kwargs)
1141-
1142-    def clean(self, value):
1143-        if value in self.empty_values:
1144-            if self.pk_field:
1145-                return None
1146-            # if there is no value act as we did before.
1147-            return self.parent_instance
1148-        # ensure the we compare the values as equal types.
1149-        if self.to_field:
1150-            orig = getattr(self.parent_instance, self.to_field)
1151-        else:
1152-            orig = self.parent_instance.pk
```

**assistant → tool `bash`**

```json
{
  "command": "git log --all --oneline -- django/forms/models.py | head -20; git branch -a; grep -rn \"edit_only\" docs tests django 2>/dev/null | head"
}
```

**tool result**

```
7b8beeee3d Fixed #33155 -- Made ModelChoiceIteratorValue instances hashable.
456466d932 Fixed #31026 -- Switched form rendering to template engine.
0e8be73812 Fixed #32975 -- Fixed admin system check for inlines with foreign keys to proxy models.
1adc09064f Fixed #32347 -- Made ModelChoiceField include the value in ValidationError for invalid_choice.
bf770cc825 Refs #8760 -- Removed "list" message for ModelMultipleChoiceField per deprecation timeline.
556fa4bbba Fixed #1891, Fixed #11707 -- Prevented duplicates with limit_choices_to on multi-value relations.
e74b3d724e Bumped minimum isort version to 5.1.0.
162765d6c3 Fixed #9061 -- Allowed FormSets to disable deleting extra forms.
433dd737f9 Fixed #20347 -- Allowed customizing the maximum number of instantiated forms in formsets.
ccf32aca44 Fixed #8760 -- Changed ModelMultipleChoiceField to use invalid_list as a error message key.
da79ee472d Fixed #26813 -- Prevented empty choice in ModelChoiceField with RadioSelect for fields with blank=False.
335c9c94ac Simplified imports from django.db and django.contrib.gis.db.
67ea35df52 Fixed #30998 -- Added ModelChoiceIteratorValue to pass the model instance to ChoiceWidget.create_option().
f4647179cc Fixed #31086 -- Improved error message for admin model inlines with more than one foreign key to the same parent.
86a0231e0a Refs #23919 -- Replaced super(...) with super() in metaclasses.
e7cdb0cd7e Fixed #30014 -- Fixed ModelChoiceField validation when initial value is a model instance.
42b9a23267 Fixed #30400 -- Improved typography of user facing strings.
a387ef1117 Added missing form argument in modelform_factory() docstring.
aa94f7c899 Fixed #30534 -- Fixed overriding a field's default in ModelForm.cleaned_data().
1ffddfc233 Fixed #30302 -- Fixed forms.model_to_dict() result if empty list of fields is passed.
* main
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '840,900p' docs/topics/forms/modelforms.txt; sed -n '1240,1270p' docs/topics/forms/modelforms.txt; grep -n \"can_delete_extra\\|absolute_max\" docs/ref/forms/models.txt docs/topics/forms/modelforms.txt | head -30"
}
```

**tool result**

```

        def clean_name(self):
            # custom validation for the name field
            ...

Then, pass your model form to the factory function::

    AuthorFormSet = modelformset_factory(Author, form=AuthorForm)

It is not always necessary to define a custom model form. The
``modelformset_factory`` function has several arguments which are
passed through to ``modelform_factory``, which are described below.

Specifying widgets to use in the form with ``widgets``
------------------------------------------------------

Using the ``widgets`` parameter, you can specify a dictionary of values to
customize the ``ModelForm``’s widget class for a particular field. This
works the same way as the ``widgets`` dictionary on the inner ``Meta``
class of a ``ModelForm`` works::

    >>> AuthorFormSet = modelformset_factory(
    ...     Author, fields=('name', 'title'),
    ...     widgets={'name': Textarea(attrs={'cols': 80, 'rows': 20})})

Enabling localization for fields with ``localized_fields``
----------------------------------------------------------

Using the ``localized_fields`` parameter, you can enable localization for
fields in the form.

    >>> AuthorFormSet = modelformset_factory(
    ...     Author, fields=('name', 'title', 'birth_date'),
    ...     localized_fields=('birth_date',))

If ``localized_fields`` is set to the special value ``'__all__'``, all fields
will be localized.

Providing initial values
------------------------

As with regular formsets, it's possible to :ref:`specify initial data
<formsets-initial-data>` for forms in the formset by specifying an ``initial``
parameter when instantiating the model formset class returned by
:func:`~django.forms.models.modelformset_factory`. However, with model
formsets, the initial values only apply to extra forms, those that aren't
attached to an existing model instance. If the length of ``initial`` exceeds
the number of extra forms, the excess initial data is ignored. If the extra
forms with initial data aren't changed by the user, they won't be validated or
saved.

.. _saving-objects-in-the-formset:

Saving objects in the formset
-----------------------------

As with a ``ModelForm``, you can save the data as a model object. This is done
with the formset's ``save()`` method::

    # Create a formset instance with POST data.
    >>> formset = AuthorFormSet(request.POST)
                return HttpResponseRedirect(author.get_absolute_url())
        else:
            formset = BookInlineFormSet(instance=author)
        return render(request, 'manage_books.html', {'formset': formset})

Notice how we pass ``instance`` in both the ``POST`` and ``GET`` cases.

Specifying widgets to use in the inline form
--------------------------------------------


``inlineformset_factory`` uses ``modelformset_factory`` and passes most
of its arguments to ``modelformset_factory``. This means you can use
the ``widgets`` parameter in much the same way as passing it to
``modelformset_factory``. See `Specifying widgets to use in the form with
widgets`_ above.
docs/ref/forms/models.txt:55:.. function:: modelformset_factory(model, form=ModelForm, formfield_callback=None, formset=BaseModelFormSet, extra=1, can_delete=False, can_order=False, max_num=None, fields=None, exclude=None, widgets=None, validate_max=False, localized_fields=None, labels=None, help_texts=None, error_messages=None, min_num=None, validate_min=False, field_classes=None, absolute_max=None, can_delete_extra=True, renderer=None)
docs/ref/forms/models.txt:66:    ``absolute_max``, ``can_delete_extra``, and ``renderer`` are passed
docs/ref/forms/models.txt:79:.. function:: inlineformset_factory(parent_model, model, form=ModelForm, formset=BaseInlineFormSet, fk_name=None, fields=None, exclude=None, extra=3, can_order=False, can_delete=True, max_num=None, formfield_callback=None, widgets=None, validate_max=False, localized_fields=None, labels=None, help_texts=None, error_messages=None, min_num=None, validate_min=False, field_classes=None, absolute_max=None, can_delete_extra=True, renderer=None)
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '45,100p' docs/ref/forms/models.txt; sed -n '1,80p' tests/forms_tests/tests/test_formsets.py; grep -n \"class BaseModelFormSetTests\\|class ModelFormSetTest\\|class InlineFormSet\" tests/forms_tests/tests/test_formsets.py"
}
```

**tool result**

```
You must provide the list of fields explicitly, either via keyword arguments
    ``fields`` or ``exclude``, or the corresponding attributes on the form's
    inner ``Meta`` class. See :ref:`modelforms-selecting-fields` for more
    information. Omitting any definition of the fields to use will result in
    an :exc:`~django.core.exceptions.ImproperlyConfigured` exception.

``modelformset_factory``
========================

.. function:: modelformset_factory(model, form=ModelForm, formfield_callback=None, formset=BaseModelFormSet, extra=1, can_delete=False, can_order=False, max_num=None, fields=None, exclude=None, widgets=None, validate_max=False, localized_fields=None, labels=None, help_texts=None, error_messages=None, min_num=None, validate_min=False, field_classes=None, absolute_max=None, can_delete_extra=True, renderer=None)

    Returns a ``FormSet`` class for the given ``model`` class.

    Arguments ``model``, ``form``, ``fields``, ``exclude``,
    ``formfield_callback``, ``widgets``, ``localized_fields``, ``labels``,
    ``help_texts``, ``error_messages``, and ``field_classes`` are all passed
    through to :func:`~django.forms.models.modelform_factory`.

    Arguments ``formset``, ``extra``, ``can_delete``, ``can_order``,
    ``max_num``, ``validate_max``, ``min_num``, ``validate_min``,
    ``absolute_max``, ``can_delete_extra``, and ``renderer`` are passed
    through to :func:`~django.forms.formsets.formset_factory`. See
    :doc:`formsets </topics/forms/formsets>` for details.

    See :ref:`model-formsets` for example usage.

    .. versionchanged:: 4.0

        The ``renderer`` argument was added.

``inlineformset_factory``
=========================

.. function:: inlineformset_factory(parent_model, model, form=ModelForm, formset=BaseInlineFormSet, fk_name=None, fields=None, exclude=None, extra=3, can_order=False, can_delete=True, max_num=None, formfield_callback=None, widgets=None, validate_max=False, localized_fields=None, labels=None, help_texts=None, error_messages=None, min_num=None, validate_min=False, field_classes=None, absolute_max=None, can_delete_extra=True, renderer=None)

    Returns an ``InlineFormSet`` using :func:`modelformset_factory` with
    defaults of ``formset=``:class:`~django.forms.models.BaseInlineFormSet`,
    ``can_delete=True``, and ``extra=3``.

    If your model has more than one :class:`~django.db.models.ForeignKey` to
    the ``parent_model``, you must specify a ``fk_name``.

    See :ref:`inline-formsets` for example usage.

    .. versionchanged:: 4.0

        The ``renderer`` argument was added.
import datetime
from collections import Counter
from unittest import mock

from django.core.exceptions import ValidationError
from django.forms import (
    BaseForm, CharField, DateField, FileField, Form, IntegerField,
    SplitDateTimeField, formsets,
)
from django.forms.formsets import (
    INITIAL_FORM_COUNT, MAX_NUM_FORM_COUNT, MIN_NUM_FORM_COUNT,
    TOTAL_FORM_COUNT, BaseFormSet, ManagementForm, all_valid, formset_factory,
)
from django.forms.utils import ErrorList
from django.forms.widgets import HiddenInput
from django.test import SimpleTestCase

from . import jinja2_tests


class Choice(Form):
    choice = CharField()
    votes = IntegerField()


ChoiceFormSet = formset_factory(Choice)


class ChoiceFormsetWithNonFormError(ChoiceFormSet):
    def clean(self):
        super().clean()
        raise ValidationError('non-form error')


class FavoriteDrinkForm(Form):
    name = CharField()


class BaseFavoriteDrinksFormSet(BaseFormSet):
    def clean(self):
        seen_drinks = []

        for drink in self.cleaned_data:
            if drink['name'] in seen_drinks:
                raise ValidationError('You may only specify a drink once.')

            seen_drinks.append(drink['name'])


# A FormSet that takes a list of favorite drinks and raises an error if
# there are any duplicates.
FavoriteDrinksFormSet = formset_factory(FavoriteDrinkForm, formset=BaseFavoriteDrinksFormSet, extra=3)


class CustomKwargForm(Form):
    def __init__(self, *args, custom_kwarg, **kwargs):
        self.custom_kwarg = custom_kwarg
        super().__init__(*args, **kwargs)


class FormsFormsetTestCase(SimpleTestCase):

    def make_choiceformset(
            self, formset_data=None, formset_class=ChoiceFormSet,
            total_forms=None, initial_forms=0, max_num_forms=0, min_num_forms=0, **kwargs):
        """
        Make a ChoiceFormset from the given formset_data.
        The data should be given as a list of (choice, votes) tuples.
        """
        kwargs.setdefault('prefix', 'choices')
        kwargs.setdefault('auto_id', False)

        if formset_data is None:
            return formset_class(**kwargs)

        if total_forms is None:
            total_forms = len(formset_data)

        def prefixed(*args):
            args = (kwargs['prefix'],) + args

(4.8 KB of matches through bash, all of them. jgrep keeps only the matches that matter, ranked.)

(exit status 1. In a command that only reads this is a result, not a broken command: grep found no match, or a path it names (ls, cat, head) does not exist.)
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"^class \" tests/forms_tests/tests/test_formsets.py | tail -30; grep -n \"class BaseModelFormSetTests\\|class ModelFormSetTest\\|class InlineFormSet\" tests/forms_tests/tests/test_formsets.py"
}
```

**tool result**

```
21:class Choice(Form):
29:class ChoiceFormsetWithNonFormError(ChoiceFormSet):
35:class FavoriteDrinkForm(Form):
39:class BaseFavoriteDrinksFormSet(BaseFormSet):
55:class CustomKwargForm(Form):
61:class FormsFormsetTestCase(SimpleTestCase):
1397:class Jinja2FormsFormsetTestCase(FormsFormsetTestCase):
1401:class FormsetAsTagTests(SimpleTestCase):
1450:class Jinja2FormsetAsTagTests(FormsetAsTagTests):
1454:class ArticleForm(Form):
1462:class TestIsBoundBehavior(SimpleTestCase):
1575:class TestIsBoundBehavior(TestIsBoundBehavior):
1579:class TestEmptyFormSet(SimpleTestCase):
1612:class AllValidTests(SimpleTestCase):

(exit status 1. In a command that only reads this is a result, not a broken command: grep found no match, or a path it names (ls, cat, head) does not exist.)
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"^class \\|def test_.*extra\\|def test_.*new\" tests/model_formsets/tests.py | head -60; grep -n \"edit_only\" docs/ref/forms/models.txt"
}
```

**tool result**

```
25:class DeletionTests(TestCase):
136:class ModelFormsetTest(TestCase):
680:    def test_inline_formsets_save_as_new(self):
1775:class TestModelFormsetOverridesTroughFormMeta(TestCase):
1952:    def test_modelformset_factory_can_delete_extra(self):
1965:    def test_modelformset_factory_disable_delete_extra(self):
1978:    def test_inlineformset_factory_can_delete_extra(self):
1992:    def test_inlineformset_factory_can_not_delete_extra(self):

(exit status 1. In a command that only reads this is a result, not a broken command: grep found no match, or a path it names (ls, cat, head) does not exist.)
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: /testbed/django/forms/models.py\n@@\n class BaseModelFormSet(BaseFormSet):\n     \"\"\"\n     A ``FormSet`` for editing a queryset and/or adding new objects to it.\n     \"\"\"\n     model = None\n+    edit_only = False\n@@\n     def save_new_objects(self, commit=True):\n         self.new_objects = []\n+        if self.edit_only:\n+            return self.new_objects\n         for form in self.extra_forms:\n             if not form.has_changed():\n                 continue\n@@\n def modelformset_factory(model, form=ModelForm, formfield_callback=None,\n                          formset=BaseModelFormSet, extra=1, can_delete=False,\n                          can_order=False, max_num=None, fields=None, exclude=None,\n                          widgets=None, validate_max=False, localized_fields=None,\n                          labels=None, help_texts=None, error_messages=None,\n                          min_num=None, validate_min=False, field_classes=None,\n-                         absolute_max=None, can_delete_extra=True, renderer=None):\n+                         absolute_max=None, can_delete_extra=True, renderer=None,\n+                         edit_only=False):\n@@\n     FormSet = formset_factory(form, formset, extra=extra, min_num=min_num, max_num=max_num,\n                               can_order=can_order, can_delete=can_delete,\n                               validate_min=validate_min, validate_max=validate_max,\n                               absolute_max=absolute_max, can_delete_extra=can_delete_extra,\n                               renderer=renderer)\n     FormSet.model = model\n+    FormSet.edit_only = edit_only\n     return FormSet\n@@\n def inlineformset_factory(parent_model, model, form=ModelForm,\n                           formset=BaseInlineFormSet, fk_name=None,\n                           fields=None, exclude=None, extra=3, can_order=False,\n                           can_delete=True, max_num=None, formfield_callback=None,\n                           widgets=None, validate_max=False, localized_fields=None,\n                           labels=None, help_texts=None, error_messages=None,\n                           min_num=None, validate_min=False, field_classes=None,\n-                          absolute_max=None, can_delete_extra=True, renderer=None):\n+                          absolute_max=None, can_delete_extra=True, renderer=None,\n+                          edit_only=False):\n@@\n         'absolute_max': absolute_max,\n         'can_delete_extra': can_delete_extra,\n         'renderer': renderer,\n+        'edit_only': edit_only,\n     }\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[/testbed/django/forms/models.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

/testbed/django/forms/models.py now (1434 lines), around the change:
568:    A ``FormSet`` for editing a queryset and/or adding new objects to it.
569:    """
570:    model = None
571:    edit_only = False
572:
573:    # Set of fields that must be unique among forms of this set.
574:    unique_fields = set()
…
814:
815:    def save_new_objects(self, commit=True):
816:        self.new_objects = []
817:        if self.edit_only:
818:            return self.new_objects
819:        for form in self.extra_forms:
820:            if not form.has_changed():
821:                continue
…
878:                         widgets=None, validate_max=False, localized_fields=None,
879:                         labels=None, help_texts=None, error_messages=None,
880:                         min_num=None, validate_min=False, field_classes=None,
881:                         absolute_max=None, can_delete_extra=True, renderer=None,
882:                         edit_only=False):
883:    """Return a FormSet class for the given Django model class."""
884:    meta = getattr(form, 'Meta', None)
885:    if (getattr(meta, 'fields', fields) is None and
…
900:                              absolute_max=absolute_max, can_delete_extra=can_delete_extra,
901:                              renderer=renderer)
902:    FormSet.model = model
903:    FormSet.edit_only = edit_only
904:    return FormSet
905:
906:
…
1081:                          widgets=None, validate_max=False, localized_fields=None,
1082:                          labels=None, help_texts=None, error_messages=None,
1083:                          min_num=None, validate_min=False, field_classes=None,
1084:                          absolute_max=None, can_delete_extra=True, renderer=None,
1085:                          edit_only=False):
1086:    """
1087:    Return an ``InlineFormSet`` for the given kwargs.
1088:
…
1115:        'absolute_max': absolute_max,
1116:        'can_delete_extra': can_delete_extra,
1117:        'renderer': renderer,
1118:        'edit_only': edit_only,
1119:    }
1120:    FormSet = modelformset_factory(model, **kwargs)
1121:    FormSet.fk = fk
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: /testbed/docs/ref/forms/models.txt\n@@\n-.. function:: modelformset_factory(model, form=ModelForm, formfield_callback=None, formset=BaseModelFormSet, extra=1, can_delete=False, can_order=False, max_num=None, fields=None, exclude=None, widgets=None, validate_max=False, localized_fields=None, labels=None, help_texts=None, error_messages=None, min_num=None, validate_min=False, field_classes=None, absolute_max=None, can_delete_extra=True, renderer=None)\n+.. function:: modelformset_factory(model, form=ModelForm, formfield_callback=None, formset=BaseModelFormSet, extra=1, can_delete=False, can_order=False, max_num=None, fields=None, exclude=None, widgets=None, validate_max=False, localized_fields=None, labels=None, help_texts=None, error_messages=None, min_num=None, validate_min=False, field_classes=None, absolute_max=None, can_delete_extra=True, renderer=None, edit_only=False)\n@@\n     Arguments ``formset``, ``extra``, ``can_delete``, ``can_order``,\n     ``max_num``, ``validate_max``, ``min_num``, ``validate_min``,\n-    ``absolute_max``, ``can_delete_extra``, and ``renderer`` are passed\n-    through to :func:`~django.forms.formsets.formset_factory`. See\n-    :doc:`formsets </topics/forms/formsets>` for details.\n+    ``absolute_max``, ``can_delete_extra``, and ``renderer`` are passed\n+    through to :func:`~django.forms.formsets.formset_factory`. See\n+    :doc:`formsets </topics/forms/formsets>` for details. The ``edit_only``\n+    argument is described in :ref:`model-formsets`.\n@@\n     .. versionchanged:: 4.0\n \n         The ``renderer`` argument was added.\n+\n+    .. versionchanged:: 4.1\n+\n+        The ``edit_only`` argument was added.\n@@\n-.. function:: inlineformset_factory(parent_model, model, form=ModelForm, formset=BaseInlineFormSet, fk_name=None, fields=None, exclude=None, extra=3, can_order=False, can_delete=True, max_num=None, formfield_callback=None, widgets=None, validate_max=False, localized_fields=None, labels=None, help_texts=None, error_messages=None, min_num=None, validate_min=False, field_classes=None, absolute_max=None, can_delete_extra=True, renderer=None)\n+.. function:: inlineformset_factory(parent_model, model, form=ModelForm, formset=BaseInlineFormSet, fk_name=None, fields=None, exclude=None, extra=3, can_order=False, can_delete=True, max_num=None, formfield_callback=None, widgets=None, validate_max=False, localized_fields=None, labels=None, help_texts=None, error_messages=None, min_num=None, validate_min=False, field_classes=None, absolute_max=None, can_delete_extra=True, renderer=None, edit_only=False)\n@@\n     .. versionchanged:: 4.0\n \n         The ``renderer`` argument was added.\n+\n+    .. versionchanged:: 4.1\n+\n+        The ``edit_only`` argument was added.\n*** End Patch\n"
}
```

**tool result**

```
apply_patch update /testbed/docs/ref/forms/models.txt: the lines to change in /testbed/docs/ref/forms/models.txt appear more than once (lines 72 and 90): add the unchanged line just above them as context, or an @@ line with the first line of the enclosing function. Nothing was written
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: /testbed/docs/ref/forms/models.txt\n@@\n-.. function:: modelformset_factory(model, form=ModelForm, formfield_callback=None, formset=BaseModelFormSet, extra=1, can_delete=False, can_order=False, max_num=None, fields=None, exclude=None, widgets=None, validate_max=False, localized_fields=None, labels=None, help_texts=None, error_messages=None, min_num=None, validate_min=False, field_classes=None, absolute_max=None, can_delete_extra=True, renderer=None)\n+.. function:: modelformset_factory(model, form=ModelForm, formfield_callback=None, formset=BaseModelFormSet, extra=1, can_delete=False, can_order=False, max_num=None, fields=None, exclude=None, widgets=None, validate_max=False, localized_fields=None, labels=None, help_texts=None, error_messages=None, min_num=None, validate_min=False, field_classes=None, absolute_max=None, can_delete_extra=True, renderer=None, edit_only=False)\n@@\n     Arguments ``formset``, ``extra``, ``can_delete``, ``can_order``,\n     ``max_num``, ``validate_max``, ``min_num``, ``validate_min``,\n-    ``absolute_max``, ``can_delete_extra``, and ``renderer`` are passed\n-    through to :func:`~django.forms.formsets.formset_factory`. See\n-    :doc:`formsets </topics/forms/formsets>` for details.\n+    ``absolute_max``, ``can_delete_extra``, and ``renderer`` are passed\n+    through to :func:`~django.forms.formsets.formset_factory`. See\n+    :doc:`formsets </topics/forms/formsets>` for details. The ``edit_only``\n+    argument is described in :ref:`model-formsets`.\n@@\n     .. versionchanged:: 4.0\n \n         The ``renderer`` argument was added.\n+\n+    .. versionchanged:: 4.1\n+\n+        The ``edit_only`` argument was added.\n*** End Patch\n"
}
```

**tool result**

```
apply_patch update /testbed/docs/ref/forms/models.txt: the lines to change in /testbed/docs/ref/forms/models.txt appear more than once (lines 72 and 90): add the unchanged line just above them as context, or an @@ line with the first line of the enclosing function. Nothing was written
```

**assistant → tool `read_file`**

```json
{
  "path": "/testbed/docs/ref/forms/models.txt",
  "offset": 55,
  "limit": 50
}
```

**tool result**

```
.. function:: modelformset_factory(model, form=ModelForm, formfield_callback=None, formset=BaseModelFormSet, extra=1, can_delete=False, can_order=False, max_num=None, fields=None, exclude=None, widgets=None, validate_max=False, localized_fields=None, labels=None, help_texts=None, error_messages=None, min_num=None, validate_min=False, field_classes=None, absolute_max=None, can_delete_extra=True, renderer=None)

    Returns a ``FormSet`` class for the given ``model`` class.

    Arguments ``model``, ``form``, ``fields``, ``exclude``,
    ``formfield_callback``, ``widgets``, ``localized_fields``, ``labels``,
    ``help_texts``, ``error_messages``, and ``field_classes`` are all passed
    through to :func:`~django.forms.models.modelform_factory`.

    Arguments ``formset``, ``extra``, ``can_delete``, ``can_order``,
    ``max_num``, ``validate_max``, ``min_num``, ``validate_min``,
    ``absolute_max``, ``can_delete_extra``, and ``renderer`` are passed
    through to :func:`~django.forms.formsets.formset_factory`. See
    :doc:`formsets </topics/forms/formsets>` for details.

    See :ref:`model-formsets` for example usage.

    .. versionchanged:: 4.0

        The ``renderer`` argument was added.

``inlineformset_factory``
=========================

.. function:: inlineformset_factory(parent_model, model, form=ModelForm, formset=BaseInlineFormSet, fk_name=None, fields=None, exclude=None, extra=3, can_order=False, can_delete=True, max_num=None, formfield_callback=None, widgets=None, validate_max=False, localized_fields=None, labels=None, help_texts=None, error_messages=None, min_num=None, validate_min=False, field_classes=None, absolute_max=None, can_delete_extra=True, renderer=None)

    Returns an ``InlineFormSet`` using :func:`modelformset_factory` with
    defaults of ``formset=``:class:`~django.forms.models.BaseInlineFormSet`,
    ``can_delete=True``, and ``extra=3``.

    If your model has more than one :class:`~django.db.models.ForeignKey` to
    the ``parent_model``, you must specify a ``fk_name``.

    See :ref:`inline-formsets` for example usage.

    .. versionchanged:: 4.0

        The ``renderer`` argument was added.

[lines 55-92 of /testbed/docs/ref/forms/models.txt, the end]
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: /testbed/docs/ref/forms/models.txt\n@@\n-.. function:: modelformset_factory(model, form=ModelForm, formfield_callback=None, formset=BaseModelFormSet, extra=1, can_delete=False, can_order=False, max_num=None, fields=None, exclude=None, widgets=None, validate_max=False, localized_fields=None, labels=None, help_texts=None, error_messages=None, min_num=None, validate_min=False, field_classes=None, absolute_max=None, can_delete_extra=True, renderer=None)\n+.. function:: modelformset_factory(model, form=ModelForm, formfield_callback=None, formset=BaseModelFormSet, extra=1, can_delete=False, can_order=False, max_num=None, fields=None, exclude=None, widgets=None, validate_max=False, localized_fields=None, labels=None, help_texts=None, error_messages=None, min_num=None, validate_min=False, field_classes=None, absolute_max=None, can_delete_extra=True, renderer=None, edit_only=False)\n@@\n     Arguments ``formset``, ``extra``, ``can_delete``, ``can_order``,\n     ``max_num``, ``validate_max``, ``min_num``, ``validate_min``,\n-    ``absolute_max``, ``can_delete_extra``, and ``renderer`` are passed\n-    through to :func:`~django.forms.formsets.formset_factory`. See\n-    :doc:`formsets </topics/forms/formsets>` for details.\n+    ``absolute_max``, ``can_delete_extra``, and ``renderer`` are passed\n+    through to :func:`~django.forms.formsets.formset_factory`. See\n+    :doc:`formsets </topics/forms/formsets>` for details. The ``edit_only``\n+    argument is described in :ref:`model-formsets`.\n@@\n     .. versionchanged:: 4.0\n \n         The ``renderer`` argument was added.\n+\n+    .. versionchanged:: 4.1\n+\n+        The ``edit_only`` argument was added.\n@@\n-.. function:: inlineformset_factory(parent_model, model, form=ModelForm, formset=BaseInlineFormSet, fk_name=None, fields=None, exclude=None, extra=3, can_order=False, can_delete=True, max_num=None, formfield_callback=None, widgets=None, validate_max=False, localized_fields=None, labels=None, help_texts=None, error_messages=None, min_num=None, validate_min=False, field_classes=None, absolute_max=None, can_delete_extra=True, renderer=None)\n+.. function:: inlineformset_factory(parent_model, model, form=ModelForm, formset=BaseInlineFormSet, fk_name=None, fields=None, exclude=None, extra=3, can_order=False, can_delete=True, max_num=None, formfield_callback=None, widgets=None, validate_max=False, localized_fields=None, labels=None, help_texts=None, error_messages=None, min_num=None, validate_min=False, field_classes=None, absolute_max=None, can_delete_extra=True, renderer=None, edit_only=False)\n@@\n     .. versionchanged:: 4.0\n \n         The ``renderer`` argument was added.\n+\n+    .. versionchanged:: 4.1\n+\n+        The ``edit_only`` argument was added.\n*** End Patch\n"
}
```

**tool result**

```
apply_patch update /testbed/docs/ref/forms/models.txt: the lines to change in /testbed/docs/ref/forms/models.txt appear more than once (lines 72 and 90): add the unchanged line just above them as context, or an @@ line with the first line of the enclosing function. Nothing was written
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: /testbed/docs/ref/forms/models.txt\n@@\n-.. function:: modelformset_factory(model, form=ModelForm, formfield_callback=None, formset=BaseModelFormSet, extra=1, can_delete=False, can_order=False, max_num=None, fields=None, exclude=None, widgets=None, validate_max=False, localized_fields=None, labels=None, help_texts=None, error_messages=None, min_num=None, validate_min=False, field_classes=None, absolute_max=None, can_delete_extra=True, renderer=None)\n+.. function:: modelformset_factory(model, form=ModelForm, formfield_callback=None, formset=BaseModelFormSet, extra=1, can_delete=False, can_order=False, max_num=None, fields=None, exclude=None, widgets=None, validate_max=False, localized_fields=None, labels=None, help_texts=None, error_messages=None, min_num=None, validate_min=False, field_classes=None, absolute_max=None, can_delete_extra=True, renderer=None, edit_only=False)\n@@\n     Arguments ``formset``, ``extra``, ``can_delete``, ``can_order``,\n     ``max_num``, ``validate_max``, ``min_num``, ``validate_min``,\n-    ``absolute_max``, ``can_delete_extra``, and ``renderer`` are passed\n-    through to :func:`~django.forms.formsets.formset_factory`. See\n-    :doc:`formsets </topics/forms/formsets>` for details.\n+    ``absolute_max``, ``can_delete_extra``, and ``renderer`` are passed\n+    through to :func:`~django.forms.formsets.formset_factory`. See\n+    :doc:`formsets </topics/forms/formsets>` for details. The ``edit_only``\n+    argument is described in :ref:`model-formsets`.\n@@\n     See :ref:`model-formsets` for example usage.\n \n     .. versionchanged:: 4.0\n \n         The ``renderer`` argument was added.\n+\n+    .. versionchanged:: 4.1\n+\n+        The ``edit_only`` argument was added.\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[/testbed/docs/ref/forms/models.txt] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

/testbed/docs/ref/forms/models.txt now (97 lines), around the change:
52:``modelformset_factory``
53:========================
54:
55:.. function:: modelformset_factory(model, form=ModelForm, formfield_callback=None, formset=BaseModelFormSet, extra=1, can_delete=False, can_order=False, max_num=None, fields=None, exclude=None, widgets=None, validate_max=False, localized_fields=None, labels=None, help_texts=None, error_messages=None, min_num=None, validate_min=False, field_classes=None, absolute_max=None, can_delete_extra=True, renderer=None, edit_only=False)
56:
57:    Returns a ``FormSet`` class for the given ``model`` class.
58:
…
65:    ``max_num``, ``validate_max``, ``min_num``, ``validate_min``,
66:    ``absolute_max``, ``can_delete_extra``, and ``renderer`` are passed
67:    through to :func:`~django.forms.formsets.formset_factory`. See
68:    :doc:`formsets </topics/forms/formsets>` for details. The ``edit_only``
69:    argument is described in :ref:`model-formsets`.
70:
71:    See :ref:`model-formsets` for example usage.
72:
73:    .. versionchanged:: 4.0
74:
75:        The ``renderer`` argument was added.
76:
77:    .. versionchanged:: 4.1
78:
79:        The ``edit_only`` argument was added.
80:
81:``inlineformset_factory``
82:=========================
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: /testbed/docs/ref/forms/models.txt\n@@\n-.. function:: inlineformset_factory(parent_model, model, form=ModelForm, formset=BaseInlineFormSet, fk_name=None, fields=None, exclude=None, extra=3, can_order=False, can_delete=True, max_num=None, formfield_callback=None, widgets=None, validate_max=False, localized_fields=None, labels=None, help_texts=None, error_messages=None, min_num=None, validate_min=False, field_classes=None, absolute_max=None, can_delete_extra=True, renderer=None)\n+.. function:: inlineformset_factory(parent_model, model, form=ModelForm, formset=BaseInlineFormSet, fk_name=None, fields=None, exclude=None, extra=3, can_order=False, can_delete=True, max_num=None, formfield_callback=None, widgets=None, validate_max=False, localized_fields=None, labels=None, help_texts=None, error_messages=None, min_num=None, validate_min=False, field_classes=None, absolute_max=None, can_delete_extra=True, renderer=None, edit_only=False)\n@@\n     See :ref:`inline-formsets` for example usage.\n \n     .. versionchanged:: 4.0\n \n         The ``renderer`` argument was added.\n+\n+    .. versionchanged:: 4.1\n+\n+        The ``edit_only`` argument was added.\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[/testbed/docs/ref/forms/models.txt] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

/testbed/docs/ref/forms/models.txt now (101 lines), around the change:
81:``inlineformset_factory``
82:=========================
83:
84:.. function:: inlineformset_factory(parent_model, model, form=ModelForm, formset=BaseInlineFormSet, fk_name=None, fields=None, exclude=None, extra=3, can_order=False, can_delete=True, max_num=None, formfield_callback=None, widgets=None, validate_max=False, localized_fields=None, labels=None, help_texts=None, error_messages=None, min_num=None, validate_min=False, field_classes=None, absolute_max=None, can_delete_extra=True, renderer=None, edit_only=False)
85:
86:    Returns an ``InlineFormSet`` using :func:`modelformset_factory` with
87:    defaults of ``formset=``:class:`~django.forms.models.BaseInlineFormSet`,
…
95:    .. versionchanged:: 4.0
96:
97:        The ``renderer`` argument was added.
98:
99:    .. versionchanged:: 4.1
100:
101:        The ``edit_only`` argument was added.
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"can_delete_extra\\|can_delete\" docs/topics/forms/modelforms.txt | head; ls docs/releases | tail; grep -n \"forms\" docs/releases/4.1.txt | head"
}
```

**tool result**

```
1164:    ``can_delete=True``.
1168:    :ref:`Manually rendered can_delete and can_order <manually-rendered-can-delete-and-can-order>`.
3.2.7.txt
3.2.8.txt
3.2.9.txt
3.2.txt
4.0.1.txt
4.0.2.txt
4.0.txt
4.1.txt
index.txt
security.txt
188:* The new :meth:`~django.forms.BoundField.legend_tag` allows rendering field
190:  :meth:`~django.forms.BoundField.label_tag`.
231:  references to fields and transforms.
374:  for CSS :doc:`form media </topics/forms/media>`.
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '180,260p' docs/releases/4.1.txt; grep -n \"Forms$\" docs/releases/4.1.txt"
}
```

**tool result**

```
File Uploads
~~~~~~~~~~~~

* ...

Forms
~~~~~

* The new :meth:`~django.forms.BoundField.legend_tag` allows rendering field
  labels in ``<legend>`` tags via the new ``tag`` argument of
  :meth:`~django.forms.BoundField.label_tag`.

Generic Views
~~~~~~~~~~~~~

* ...

Internationalization
~~~~~~~~~~~~~~~~~~~~

* The :func:`~django.conf.urls.i18n.i18n_patterns` function now supports
  languages with both scripts and regions.

Logging
~~~~~~~

* ...

Management Commands
~~~~~~~~~~~~~~~~~~~

* :option:`makemigrations --no-input` now logs default answers and reasons why
  migrations cannot be created.

* The new :option:`makemigrations --scriptable` option diverts log output and
  input prompts to ``stderr``, writing only paths of generated migration files
  to ``stdout``.

* The new :option:`migrate --prune` option allows deleting nonexistent
  migrations from the ``django_migrations`` table.

Migrations
~~~~~~~~~~

* ...

Models
~~~~~~

* The ``order_by`` argument of the
  :class:`~django.db.models.expressions.Window` expression now accepts string
  references to fields and transforms.

* The new :setting:`CONN_HEALTH_CHECKS` setting allows enabling health checks
  for :ref:`persistent database connections <persistent-database-connections>`
  in order to reduce the number of failed requests, e.g. after database server
  restart.

* :meth:`.QuerySet.bulk_create` now supports updating fields when a row
  insertion fails uniqueness constraints. This is supported on MariaDB, MySQL,
  PostgreSQL, and SQLite 3.24+.

* :meth:`.QuerySet.iterator` now supports prefetching related objects as long
  as the ``chunk_size`` argument is provided. In older versions, no prefetching
  was done.

Requests and Responses
~~~~~~~~~~~~~~~~~~~~~~

* ...

Security
~~~~~~~~

* ...

Serialization
~~~~~~~~~~~~~

* ...

185:Forms
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: /testbed/docs/releases/4.1.txt\n@@\n * The new :meth:`~django.forms.BoundField.legend_tag` allows rendering field\n   labels in ``<legend>`` tags via the new ``tag`` argument of\n   :meth:`~django.forms.BoundField.label_tag`.\n+\n+* :func:`~django.forms.models.modelformset_factory` and\n+  :func:`~django.forms.models.inlineformset_factory` now accept an\n+  ``edit_only`` argument to prevent creating new objects.\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[/testbed/docs/releases/4.1.txt] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

/testbed/docs/releases/4.1.txt now (474 lines), around the change:
188:* The new :meth:`~django.forms.BoundField.legend_tag` allows rendering field
189:  labels in ``<legend>`` tags via the new ``tag`` argument of
190:  :meth:`~django.forms.BoundField.label_tag`.
191:
192:* :func:`~django.forms.models.modelformset_factory` and
193:  :func:`~django.forms.models.inlineformset_factory` now accept an
194:  ``edit_only`` argument to prevent creating new objects.
195:
196:Generic Views
197:~~~~~~~~~~~~~
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '880,940p' docs/topics/forms/modelforms.txt"
}
```

**tool result**

```

As with regular formsets, it's possible to :ref:`specify initial data
<formsets-initial-data>` for forms in the formset by specifying an ``initial``
parameter when instantiating the model formset class returned by
:func:`~django.forms.models.modelformset_factory`. However, with model
formsets, the initial values only apply to extra forms, those that aren't
attached to an existing model instance. If the length of ``initial`` exceeds
the number of extra forms, the excess initial data is ignored. If the extra
forms with initial data aren't changed by the user, they won't be validated or
saved.

.. _saving-objects-in-the-formset:

Saving objects in the formset
-----------------------------

As with a ``ModelForm``, you can save the data as a model object. This is done
with the formset's ``save()`` method::

    # Create a formset instance with POST data.
    >>> formset = AuthorFormSet(request.POST)

    # Assuming all is valid, save the data.
    >>> instances = formset.save()

The ``save()`` method returns the instances that have been saved to the
database. If a given instance's data didn't change in the bound data, the
instance won't be saved to the database and won't be included in the return
value (``instances``, in the above example).

When fields are missing from the form (for example because they have been
excluded), these fields will not be set by the ``save()`` method. You can find
more information about this restriction, which also holds for regular
``ModelForms``, in `Selecting the fields to use`_.

Pass ``commit=False`` to return the unsaved model instances::

    # don't save to the database
    >>> instances = formset.save(commit=False)
    >>> for instance in instances:
    ...     # do something with instance
    ...     instance.save()

This gives you the ability to attach data to the instances before saving them
to the database. If your formset contains a ``ManyToManyField``, you'll also
need to call ``formset.save_m2m()`` to ensure the many-to-many relationships
are saved properly.

After calling ``save()``, your model formset will have three new attributes
containing the formset's changes:

.. attribute:: models.BaseModelFormSet.changed_objects
.. attribute:: models.BaseModelFormSet.deleted_objects
.. attribute:: models.BaseModelFormSet.new_objects

.. _model-formsets-max-num:

Limiting the number of editable objects
---------------------------------------

As with regular formsets, you can use the ``max_num`` and ``extra`` parameters
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '1,30p' tests/model_formsets/tests.py; sed -n '1940,2010p' tests/model_formsets/tests.py; sed -n '1270,1300p' tests/forms_tests/tests/test_formsets.py"
}
```

**tool result**

```
import datetime
import re
from datetime import date
from decimal import Decimal

from django import forms
from django.core.exceptions import ImproperlyConfigured
from django.db import models
from django.forms.models import (
    BaseModelFormSet, _get_foreign_key, inlineformset_factory,
    modelformset_factory,
)
from django.http import QueryDict
from django.test import TestCase, skipUnlessDBFeature

from .models import (
    AlternateBook, Author, AuthorMeeting, BetterAuthor, Book, BookWithCustomPK,
    BookWithOptionalAltEditor, ClassyMexicanRestaurant, CustomPrimaryKey,
    Location, Membership, MexicanRestaurant, Owner, OwnerProfile, Person,
    Place, Player, Poem, Poet, Post, Price, Product, Repository, Restaurant,
    Revision, Team,
)


class DeletionTests(TestCase):
    def test_deletion(self):
        PoetFormSet = modelformset_factory(Poet, fields="__all__", can_delete=True)
        poet = Poet.objects.create(name='test')
        data = {
            'form-TOTAL_FORMS': '1',
            'book_set-TOTAL_FORMS': '101',
            'book_set-INITIAL_FORMS': '0',
            'book_set-MAX_NUM_FORMS': '0',
        }
        formset = BookFormSet(data, instance=author)
        self.assertIs(formset.is_valid(), False)
        self.assertEqual(len(formset.forms), 100)
        self.assertEqual(
            formset.non_form_errors(),
            ['Please submit at most 20 forms.'],
        )

    def test_modelformset_factory_can_delete_extra(self):
        AuthorFormSet = modelformset_factory(
            Author,
            fields='__all__',
            can_delete=True,
            can_delete_extra=True,
            extra=2,
        )
        formset = AuthorFormSet()
        self.assertEqual(len(formset), 2)
        self.assertIn('DELETE', formset.forms[0].fields)
        self.assertIn('DELETE', formset.forms[1].fields)

    def test_modelformset_factory_disable_delete_extra(self):
        AuthorFormSet = modelformset_factory(
            Author,
            fields='__all__',
            can_delete=True,
            can_delete_extra=False,
            extra=2,
        )
        formset = AuthorFormSet()
        self.assertEqual(len(formset), 2)
        self.assertNotIn('DELETE', formset.forms[0].fields)
        self.assertNotIn('DELETE', formset.forms[1].fields)

    def test_inlineformset_factory_can_delete_extra(self):
        BookFormSet = inlineformset_factory(
            Author,
            Book,
            fields='__all__',
            can_delete=True,
            can_delete_extra=True,
            extra=2,
        )
        formset = BookFormSet()
        self.assertEqual(len(formset), 2)
        self.assertIn('DELETE', formset.forms[0].fields)
        self.assertIn('DELETE', formset.forms[1].fields)

    def test_inlineformset_factory_can_not_delete_extra(self):
        BookFormSet = inlineformset_factory(
            Author,
            Book,
            fields='__all__',
            can_delete=True,
            can_delete_extra=False,
            extra=2,
        )
        formset = BookFormSet()
        self.assertEqual(len(formset), 2)
        self.assertNotIn('DELETE', formset.forms[0].fields)
        self.assertNotIn('DELETE', formset.forms[1].fields)

    def test_inlineformset_factory_passes_renderer(self):
        from django.forms.renderers import Jinja2
        renderer = Jinja2()
        BookFormSet = inlineformset_factory(
            Author,
        ChoiceFormFormset = formset_factory(form=Choice, can_delete=True, extra=2)
        formset = ChoiceFormFormset()
        self.assertEqual(len(formset), 2)
        self.assertIn('DELETE', formset.forms[0].fields)
        self.assertIn('DELETE', formset.forms[1].fields)

    def test_disable_delete_extra_formset_forms(self):
        ChoiceFormFormset = formset_factory(
            form=Choice,
            can_delete=True,
            can_delete_extra=False,
            extra=2,
        )
        formset = ChoiceFormFormset()
        self.assertEqual(len(formset), 2)
        self.assertNotIn('DELETE', formset.forms[0].fields)
        self.assertNotIn('DELETE', formset.forms[1].fields)

        formset = ChoiceFormFormset(initial=[{'choice': 'Zero', 'votes': '1'}])
        self.assertEqual(len(formset), 3)
        self.assertIn('DELETE', formset.forms[0].fields)
        self.assertNotIn('DELETE', formset.forms[1].fields)
        self.assertNotIn('DELETE', formset.forms[2].fields)

        formset = ChoiceFormFormset(data={
            'form-0-choice': 'Zero',
            'form-0-votes': '0',
            'form-0-DELETE': 'on',
            'form-1-choice': 'One',
            'form-1-votes': '1',
            'form-2-choice': '',
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: /testbed/tests/model_formsets/tests.py\n@@\n     def test_modelformset_factory_disable_delete_extra(self):\n         AuthorFormSet = modelformset_factory(\n             Author,\n             fields='__all__',\n             can_delete=True,\n@@\n         self.assertEqual(len(formset), 2)\n         self.assertNotIn('DELETE', formset.forms[0].fields)\n         self.assertNotIn('DELETE', formset.forms[1].fields)\n \n+    def test_modelformset_factory_edit_only(self):\n+        AuthorFormSet = modelformset_factory(\n+            Author,\n+            fields='__all__',\n+            edit_only=True,\n+        )\n+        author = Author.objects.create(name='test')\n+        data = {\n+            'form-TOTAL_FORMS': '2',\n+            'form-INITIAL_FORMS': '1',\n+            'form-0-name': 'test',\n+            'form-0-id': str(author.pk),\n+            'form-1-name': 'new',\n+        }\n+        formset = AuthorFormSet(data)\n+        self.assertIs(formset.is_valid(), True)\n+        formset.save()\n+        self.assertEqual(Author.objects.count(), 1)\n+\n     def test_inlineformset_factory_can_delete_extra(self):\n         BookFormSet = inlineformset_factory(\n             Author,\n             Book,\n             fields='__all__',\n@@\n         self.assertEqual(len(formset), 2)\n         self.assertNotIn('DELETE', formset.forms[0].fields)\n         self.assertNotIn('DELETE', formset.forms[1].fields)\n \n+    def test_inlineformset_factory_edit_only(self):\n+        BookFormSet = inlineformset_factory(\n+            Author,\n+            Book,\n+            fields='__all__',\n+            edit_only=True,\n+        )\n+        author = Author.objects.create(name='test')\n+        book = Book.objects.create(name='test', author=author)\n+        data = {\n+            'book_set-TOTAL_FORMS': '2',\n+            'book_set-INITIAL_FORMS': '1',\n+            'book_set-0-name': 'test',\n+            'book_set-0-id': str(book.pk),\n+            'book_set-0-author': str(author.pk),\n+            'book_set-1-name': 'new',\n+        }\n+        formset = BookFormSet(data, instance=author)\n+        self.assertIs(formset.is_valid(), True)\n+        formset.save()\n+        self.assertEqual(Book.objects.count(), 1)\n+\n     def test_inlineformset_factory_passes_renderer(self):\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[/testbed/tests/model_formsets/tests.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

/testbed/tests/model_formsets/tests.py now (2064 lines), around the change:
1975:        self.assertNotIn('DELETE', formset.forms[0].fields)
1976:        self.assertNotIn('DELETE', formset.forms[1].fields)
1977:
1978:    def test_modelformset_factory_edit_only(self):
1979:        AuthorFormSet = modelformset_factory(
1980:            Author,
1981:            fields='__all__',
1982:            edit_only=True,
1983:        )
1984:        author = Author.objects.create(name='test')
1985:        data = {
1986:            'form-TOTAL_FORMS': '2',
1987:            'form-INITIAL_FORMS': '1',
1988:            'form-0-name': 'test',
1989:            'form-0-id': str(author.pk),
1990:            'form-1-name': 'new',
1991:        }
1992:        formset = AuthorFormSet(data)
1993:        self.assertIs(formset.is_valid(), True)
1994:        formset.save()
1995:        self.assertEqual(Author.objects.count(), 1)
1996:
1997:    def test_inlineformset_factory_can_delete_extra(self):
1998:        BookFormSet = inlineformset_factory(
1999:            Author,
…
2022:        self.assertNotIn('DELETE', formset.forms[0].fields)
2023:        self.assertNotIn('DELETE', formset.forms[1].fields)
2024:
2025:    def test_inlineformset_factory_edit_only(self):
2026:        BookFormSet = inlineformset_factory(
2027:            Author,
2028:            Book,
2029:            fields='__all__',
2030:            edit_only=True,
2031:        )
2032:        author = Author.objects.create(name='test')
2033:        book = Book.objects.create(name='test', author=author)
2034:        data = {
2035:            'book_set-TOTAL_FORMS': '2',
2036:            'book_set-INITIAL_FORMS': '1',
2037:            'book_set-0-name': 'test',
2038:            'book_set-0-id': str(book.pk),
2039:            'book_set-0-author': str(author.pk),
2040:            'book_set-1-name': 'new',
2041:        }
2042:        formset = BookFormSet(data, instance=author)
2043:        self.assertIs(formset.is_valid(), True)
2044:        formset.save()
2045:        self.assertEqual(Book.objects.count(), 1)
2046:
2047:    def test_inlineformset_factory_passes_renderer(self):
2048:        from django.forms.renderers import Jinja2
2049:        renderer = Jinja2()
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: /testbed/docs/topics/forms/modelforms.txt\n@@\n After calling ``save()``, your model formset will have three new attributes\n containing the formset's changes:\n \n .. attribute:: models.BaseModelFormSet.changed_objects\n .. attribute:: models.BaseModelFormSet.deleted_objects\n .. attribute:: models.BaseModelFormSet.new_objects\n \n+.. _model-formsets-edit-only:\n+\n+Preventing new objects from being created\n+-----------------------------------------\n+\n+The ``edit_only`` argument of\n+:func:`~django.forms.models.modelformset_factory` and\n+:func:`~django.forms.models.inlineformset_factory` prevents the creation of new\n+objects. Note that ``extra=0`` is not sufficient for this, as additional forms\n+can be added by submitting extra form data::\n+\n+    >>> AuthorFormSet = modelformset_factory(\n+    ...     Author, fields=('name', 'title'), edit_only=True)\n+\n .. _model-formsets-max-num:\n \n Limiting the number of editable objects\n ---------------------------------------\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[/testbed/docs/topics/forms/modelforms.txt] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

/testbed/docs/topics/forms/modelforms.txt now (1269 lines), around the change:
932:.. attribute:: models.BaseModelFormSet.deleted_objects
933:.. attribute:: models.BaseModelFormSet.new_objects
934:
935:.. _model-formsets-edit-only:
936:
937:Preventing new objects from being created
938:-----------------------------------------
939:
940:The ``edit_only`` argument of
941::func:`~django.forms.models.modelformset_factory` and
942::func:`~django.forms.models.inlineformset_factory` prevents the creation of new
943:objects. Note that ``extra=0`` is not sufficient for this, as additional forms
944:can be added by submitting extra form data::
945:
946:    >>> AuthorFormSet = modelformset_factory(
947:    ...     Author, fields=('name', 'title'), edit_only=True)
948:
949:.. _model-formsets-max-num:
950:
951:Limiting the number of editable objects
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '940,948p' docs/topics/forms/modelforms.txt"
}
```

**tool result**

```
The ``edit_only`` argument of
:func:`~django.forms.models.modelformset_factory` and
:func:`~django.forms.models.inlineformset_factory` prevents the creation of new
objects. Note that ``extra=0`` is not sufficient for this, as additional forms
can be added by submitting extra form data::

    >>> AuthorFormSet = modelformset_factory(
    ...     Author, fields=('name', 'title'), edit_only=True)
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"func:\\`~django.forms.models.modelformset_factory\\` and\" docs/topics/forms/modelforms.txt"
}
```

**tool result**

```
941::func:`~django.forms.models.modelformset_factory` and
1177:    :func:`~django.forms.models.modelformset_factory` and marks
```

**assistant → tool `bash`**

```json
{
  "command": "cd tests && python runtests.py model_formsets.tests.ModelFormsetTest.test_modelformset_factory_edit_only model_formsets.tests.ModelFormsetTest.test_inlineformset_factory_edit_only -v 2 2>&1 | tail -30"
}
```

**tool result**

```
test_modelformset_factory_edit_only (unittest.loader._FailedTest) ... ERROR
test_inlineformset_factory_edit_only (unittest.loader._FailedTest) ... ERROR

======================================================================
ERROR: test_modelformset_factory_edit_only (unittest.loader._FailedTest)
----------------------------------------------------------------------
AttributeError: type object 'ModelFormsetTest' has no attribute 'test_modelformset_factory_edit_only'

======================================================================
ERROR: test_inlineformset_factory_edit_only (unittest.loader._FailedTest)
----------------------------------------------------------------------
AttributeError: type object 'ModelFormsetTest' has no attribute 'test_inlineformset_factory_edit_only'

----------------------------------------------------------------------
Ran 2 tests in 0.000s

FAILED (errors=2)
Testing against Django installed in '/testbed/django' with up to 8 processes
Importing application model_formsets
Found 2 test(s).
Skipping setup of unused database(s): default, other.
System check identified no issues (1 silenced).
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"^class \" tests/model_formsets/tests.py | tail -10"
}
```

**tool result**

```
25:class DeletionTests(TestCase):
136:class ModelFormsetTest(TestCase):
1775:class TestModelFormsetOverridesTroughFormMeta(TestCase):
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '1775,1785p' tests/model_formsets/tests.py; cd tests && python runtests.py model_formsets.tests.TestModelFormsetOverridesTroughFormMeta.test_modelformset_factory_edit_only model_formsets.tests.TestModelFormsetOverridesTroughFormMeta.test_inlineformset_factory_edit_only -v 2 2>&1 | tail -30"
}
```

**tool result**

```
class TestModelFormsetOverridesTroughFormMeta(TestCase):
    def test_modelformset_factory_widgets(self):
        widgets = {
            'name': forms.TextInput(attrs={'class': 'poet'})
        }
        PoetFormSet = modelformset_factory(Poet, fields="__all__", widgets=widgets)
        form = PoetFormSet.form()
        self.assertHTMLEqual(
            str(form['name']),
            '<input id="id_name" maxlength="100" type="text" class="poet" name="name" required>'
        )
    Running deferred SQL...
Running migrations:
  Applying admin.0001_initial... OK
  Applying admin.0002_logentry_remove_auto_add... OK
  Applying admin.0003_logentry_add_action_flag_choices... OK
  Applying sites.0001_initial... OK
  Applying sites.0002_alter_domain_unique... OK
System check identified no issues (1 silenced).
test_modelformset_factory_edit_only (model_formsets.tests.TestModelFormsetOverridesTroughFormMeta) ... ok
test_inlineformset_factory_edit_only (model_formsets.tests.TestModelFormsetOverridesTroughFormMeta) ... ERROR

======================================================================
ERROR: test_inlineformset_factory_edit_only (model_formsets.tests.TestModelFormsetOverridesTroughFormMeta)
----------------------------------------------------------------------
Traceback (most recent call last):
  File "/testbed/tests/model_formsets/tests.py", line 2033, in test_inlineformset_factory_edit_only
    book = Book.objects.create(name='test', author=author)
  File "/testbed/django/db/models/manager.py", line 85, in manager_method
    return getattr(self.get_queryset(), name)(*args, **kwargs)
  File "/testbed/django/db/models/query.py", line 484, in create
    obj = self.model(**kwargs)
  File "/testbed/django/db/models/base.py", line 533, in __init__
    raise TypeError(
TypeError: Book() got unexpected keyword arguments: 'name'

----------------------------------------------------------------------
Ran 2 tests in 0.009s

FAILED (errors=1)
Destroying test database for alias 'default' ('file:memorydb_default?mode=memory&cache=shared')...
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"class Book(\" -A20 tests/model_formsets/models.py"
}
```

**tool result**

```
21:class Book(models.Model):
22-    author = models.ForeignKey(Author, models.CASCADE)
23-    title = models.CharField(max_length=100)
24-
25-    class Meta:
26-        unique_together = (
27-            ('author', 'title'),
28-        )
29-        ordering = ['id']
30-
31-    def __str__(self):
32-        return self.title
33-
34-    def clean(self):
35-        # Ensure author is always accessible in clean method
36-        assert self.author.name is not None
37-
38-
39-class BookWithCustomPK(models.Model):
40-    my_pk = models.DecimalField(max_digits=5, decimal_places=0, primary_key=True)
41-    author = models.ForeignKey(Author, models.CASCADE)
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: /testbed/tests/model_formsets/tests.py\n@@\n-        book = Book.objects.create(name='test', author=author)\n+        book = Book.objects.create(title='test', author=author)\n         data = {\n             'book_set-TOTAL_FORMS': '2',\n             'book_set-INITIAL_FORMS': '1',\n-            'book_set-0-name': 'test',\n+            'book_set-0-title': 'test',\n             'book_set-0-id': str(book.pk),\n             'book_set-0-author': str(author.pk),\n-            'book_set-1-name': 'new',\n+            'book_set-1-title': 'new',\n         }\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[/testbed/tests/model_formsets/tests.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

/testbed/tests/model_formsets/tests.py now (2064 lines), around the change:
2030:            edit_only=True,
2031:        )
2032:        author = Author.objects.create(name='test')
2033:        book = Book.objects.create(title='test', author=author)
2034:        data = {
2035:            'book_set-TOTAL_FORMS': '2',
2036:            'book_set-INITIAL_FORMS': '1',
2037:            'book_set-0-title': 'test',
2038:            'book_set-0-id': str(book.pk),
2039:            'book_set-0-author': str(author.pk),
2040:            'book_set-1-title': 'new',
2041:        }
2042:        formset = BookFormSet(data, instance=author)
2043:        self.assertIs(formset.is_valid(), True)
```

**assistant → tool `bash`**

```json
{
  "command": "cd tests && python runtests.py model_formsets.tests.TestModelFormsetOverridesTroughFormMeta.test_modelformset_factory_edit_only model_formsets.tests.TestModelFormsetOverridesTroughFormMeta.test_inlineformset_factory_edit_only -v 2 2>&1 | tail -30"
}
```

**tool result**

```
    Creating table model_formsets_membership
    Creating table model_formsets_team
    Creating table model_formsets_player
    Creating table model_formsets_poet
    Creating table model_formsets_poem
    Creating table model_formsets_post
    Creating table model_formsets_uuidpkparent
    Creating table model_formsets_uuidpkchild
    Creating table model_formsets_childwitheditablepk
    Creating table model_formsets_autopkchildofuuidpkparent
    Creating table model_formsets_autopkparent
    Creating table model_formsets_uuidpkchildofautopkparent
    Creating table model_formsets_parentwithuuidalternatekey
    Creating table model_formsets_childrelatedviaak
    Running deferred SQL...
Running migrations:
  Applying admin.0001_initial... OK
  Applying admin.0002_logentry_remove_auto_add... OK
  Applying admin.0003_logentry_add_action_flag_choices... OK
  Applying sites.0001_initial... OK
  Applying sites.0002_alter_domain_unique... OK
System check identified no issues (1 silenced).
test_modelformset_factory_edit_only (model_formsets.tests.TestModelFormsetOverridesTroughFormMeta) ... ok
test_inlineformset_factory_edit_only (model_formsets.tests.TestModelFormsetOverridesTroughFormMeta) ... ok

----------------------------------------------------------------------
Ran 2 tests in 0.009s

OK
Destroying test database for alias 'default' ('file:memorydb_default?mode=memory&cache=shared')...
```

**assistant → tool `bash`**

```json
{
  "command": "cd tests && python runtests.py model_formsets forms_tests -v 1 2>&1 | tail -15"
}
```

**tool result**

```
System check identified no issues (1 silenced).
.....................................................................................................................................................................................................................................................................................................................................................................................................s............................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................
----------------------------------------------------------------------
Ran 962 tests in 1.533s

OK (skipped=1)
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
Destroying test database for alias 'default'...
```

**assistant → tool `bash`**

```json
{
  "command": "git status --porcelain -- . ':(exclude).memdoor'; test -n \"$(git status --porcelain -- . ':(exclude).memdoor')\" && echo PASS"
}
```

**tool result**

```
 M django/forms/models.py
 M docs/ref/forms/models.txt
 M docs/releases/4.1.txt
 M docs/topics/forms/modelforms.txt
 M tests/model_formsets/tests.py
PASS
```

**assistant**

```
Implemented `edit_only` support for model formsets.

Changes:
- **`django/forms/models.py`**
  - Added `BaseModelFormSet.edit_only = False`.
  - `save_new_objects()` returns no new objects when `edit_only=True`.
  - Added `edit_only=False` to `modelformset_factory()` and `inlineformset_factory()`; it's propagated to the generated formset class.
- **Tests** — Added coverage for both `modelformset_factory(edit_only=True)` and `inlineformset_factory(edit_only=True)` verifying submitted extra forms aren't saved.
- **Docs** — Updated API docs, added an “edit only” section to the model formsets topic guide, and noted the feature in the 4.1 release notes.

Verification: `model_formsets` and `forms_tests` suites pass (962 tests, 1 skipped), and the completion command exits 0.
```

## Run folder `single-2026-11-06T111308`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `prompt.md`

```
Provide a way for model formsets to disallow new object creation
Description
	
Model formsets don't provide a way to create an "edit only" view of objects. We see users trying to use extra=0 to accomplish this, but that's not reliable as extra is merely meant for the extra number of forms to display. You can add more forms with Javascript (or just send additional post data).
```
