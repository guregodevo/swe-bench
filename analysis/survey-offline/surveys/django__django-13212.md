# Survey: validators omit the provided value from ValidationError

Each line names a code path that raises `ValidationError` without a `value` entry in `params`, so a custom message using the documented `%(value)s` placeholder cannot render the offending input.

## Built-in validators named by the issue (`django/core/validators.py`)

- `django/core/validators.py:RegexValidator.__call__` — raises `ValidationError(self.message, code=self.code)` with no `params`, so the base regex validator (and every subclass that delegates to it) cannot interpolate `%(value)s`.
- `django/core/validators.py:URLValidator.__call__` — raises the URL error at five separate points (non-string, bad scheme, unparsable URL, invalid IPv6 host, host longer than 253 chars) all without `params={'value': value}`.
- `django/core/validators.py:EmailValidator.__call__` — raises the email error for missing `@`, bad user part, and bad domain part without passing the submitted address as `value`.
- `django/core/validators.py:validate_ipv4_address` — raises `Enter a valid IPv4 address.` without `params={'value': value}`.
- `django/core/validators.py:validate_ipv6_address` — raises `Enter a valid IPv6 address.` without `params={'value': value}`.
- `django/core/validators.py:validate_ipv46_address` — raises `Enter a valid IPv4 or IPv6 address.` without `params={'value': value}`.
- `django/core/validators.py:DecimalValidator.__call__` — raises the `invalid`, `max_digits`, `max_decimal_places`, and `max_whole_digits` errors with only `max` in `params`, omitting `value`.
- `django/core/validators.py:FileExtensionValidator.__call__` — raises the `invalid_extension` error with `extension`/`allowed_extensions` but not the file object as `value`.
- `django/core/validators.py:ProhibitNullCharactersValidator.__call__` — raises the null-character error without `params={'value': value}`.
- `django/core/validators.py:BaseValidator.__call__` — already passes `value` in `params`, the one core path that does it correctly and the model the others should follow (covers `MaxValueValidator`, `MinValueValidator`, `MinLengthValidator`, `MaxLengthValidator`).

## Sibling validators that do the same thing the same way

- `django/contrib/auth/validators.py:ASCIIUsernameValidator` — inherits `RegexValidator.__call__`, so username validation also omits the value.
- `django/contrib/auth/validators.py:UnicodeUsernameValidator` — same inherited `RegexValidator.__call__` path, omitting the value.
- `django/contrib/postgres/validators.py:KeysValidator.__call__` — raises `missing_keys`/`extra_keys` with only `keys` in `params`, omitting the submitted mapping as `value`.
- `django/contrib/postgres/validators.py:ArrayMaxLengthValidator` — inherits `BaseValidator.__call__` and therefore already includes `value` (parallel class that is already correct).
- `django/contrib/postgres/validators.py:ArrayMinLengthValidator` — inherits `BaseValidator.__call__` and therefore already includes `value` (parallel class that is already correct).
- `django/contrib/postgres/validators.py:RangeMaxValueValidator` — inherits `BaseValidator.__call__` and therefore already includes `value` (parallel class that is already correct).
- `django/contrib/postgres/validators.py:RangeMinValueValidator` — inherits `BaseValidator.__call__` and therefore already includes `value` (parallel class that is already correct).
- `django/utils/ipv6.py:clean_ipv6_address` — raises `ValidationError(error_message, code='invalid')` without `params={'value': ip_str}`, the lower-level IPv6 path used by `GenericIPAddressField`.
- `django/contrib/sites/models.py:_simple_domain_name_validator` — raises the whitespace-in-domain error without `params={'value': value}`.
- `django/contrib/auth/password_validation.py:MinimumLengthValidator.validate` — raises `password_too_short` with only `min_length`, omitting the password as `value`.
- `django/contrib/auth/password_validation.py:UserAttributeSimilarityValidator.validate` — raises `password_too_similar` with only `verbose_name`, omitting the password as `value`.
- `django/contrib/auth/password_validation.py:CommonPasswordValidator.validate` — raises `password_too_common` with no `params` at all.
- `django/contrib/auth/password_validation.py:NumericPasswordValidator.validate` — raises `password_entirely_numeric` with no `params` at all.

## Field-level paths that raise the same value-less errors

- `django/forms/fields.py:IntegerField.to_python` — raises the `invalid` error without `params={'value': value}`.
- `django/forms/fields.py:FloatField.to_python` — raises the `invalid` error without `params={'value': value}`.
- `django/forms/fields.py:FloatField.validate` — raises the non-finite `invalid` error without `params={'value': value}`.
- `django/forms/fields.py:DecimalField.to_python` — raises the `invalid` error without `params={'value': value}`.
- `django/forms/fields.py:DecimalField.validate` — raises the non-finite `invalid` error without `params={'value': value}`.
- `django/forms/fields.py:BaseTemporalField.to_python` — raises the `invalid` error without `params={'value': value}`.
- `django/forms/fields.py:DateTimeField.to_python` — raises the `invalid` error without `params={'value': value}`.
- `django/forms/fields.py:DurationField.to_python` — raises the `invalid` error without `params={'value': value}`.
- `django/forms/fields.py:FileField.to_python` — raises `invalid`, `max_length`, and `empty` errors without the submitted file as `value`.
- `django/forms/fields.py:ImageField.to_python` — raises `invalid_image` without `params={'value': value}`.
- `django/forms/fields.py:URLField.to_python` — raises the `invalid` error without `params={'value': value}`.
- `django/forms/fields.py:UUIDField.to_python` — raises the `invalid` error without `params={'value': value}`.
- `django/forms/fields.py:JSONField.to_python` — raises the `invalid` error with `params={'value': value}` (a newer interface that already does it correctly).
- `django/forms/fields.py:ChoiceField.validate` — raises `invalid_choice` with `params={'value': value}` (already correct).
- `django/forms/fields.py:TypedChoiceField._coerce` — raises `invalid_choice` with `params={'value': value}` (already correct).
- `django/forms/fields.py:MultipleChoiceField.validate` — raises `invalid_choice` with `params={'value': val}` (already correct).
- `django/forms/fields.py:TypedMultipleChoiceField._coerce` — raises `invalid_choice` with `params={'value': choice}` (already correct).
- `django/forms/models.py:ModelChoiceField.to_python` — raises `invalid_choice` without `params={'value': value}`.
- `django/forms/models.py:ModelMultipleChoiceField._check_values` — raises `invalid_pk_value`/`invalid_choice` with `pk`/`value` in `params` (already correct).
- `django/db/models/fields/__init__.py:Field.run_validators` — re-raises collected validator errors after swapping in field error messages, so any missing `value` param from the validators above propagates to model validation.
- `django/db/models/fields/__init__.py:Field.validate` — raises `invalid_choice` with `params={'value': value}` (already correct).
- `django/db/models/fields/__init__.py:BooleanField.to_python` — raises `invalid`/`invalid_nullable` with `params={'value': value}` (already correct).
- `django/db/models/fields/__init__.py:DateField.to_python` — raises `invalid_date`/`invalid` with `params={'value': value}` (already correct).
- `django/contrib/postgres/forms/hstore.py:HStoreField.to_python` — raises `invalid_json`/`invalid_format` without `params={'value': value}`.
- `django/contrib/gis/forms/fields.py:GeometryField.to_python` — raises `invalid_geom` without `params={'value': value}`.
- `django/contrib/gis/forms/fields.py:GeometryField.clean` — raises `invalid_geom_type`/`transform_error` without `params={'value': value}`.
