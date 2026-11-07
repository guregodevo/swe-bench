# Survey: async create/get_or_create/update_or_create on related managers

## Paths the issue names

- `django/db/models/fields/related_descriptors.py:create_reverse_many_to_one_manager.RelatedManager.acreate` — the async create leaked onto reverse FK related managers; it calls `sync_to_async(self.create)`, which resolves to the QuerySet's `create()` rather than the related manager's FK-injecting `create()`, so the relation's field value is never set.
- `django/db/models/fields/related_descriptors.py:create_reverse_many_to_one_manager.RelatedManager.create` — the sync reverse-FK create that the async version should mirror: it calls `_check_fk_val()`, injects `kwargs[self.field.name] = self.instance`, and routes through `self.db_manager(db)`.
- `django/db/models/fields/related_descriptors.py:create_reverse_many_to_one_manager.RelatedManager.get_or_create` — sync reverse-FK get_or_create that injects the FK value and write DB; the inherited `aget_or_create()` bypasses it.
- `django/db/models/fields/related_descriptors.py:create_reverse_many_to_one_manager.RelatedManager.update_or_create` — sync reverse-FK update_or_create that injects the FK value and write DB; the inherited `aupdate_or_create()` bypasses it.
- `django/db/models/fields/related_descriptors.py:create_forward_many_to_many_manager.ManyRelatedManager.acreate` — the async create leaked onto forward/reverse M2M related managers; it calls `sync_to_async(self.create)`, which resolves to the QuerySet's `create()` and therefore never adds the through-table row.
- `django/db/models/fields/related_descriptors.py:create_forward_many_to_many_manager.ManyRelatedManager.create` — the sync M2M create that the async version should mirror: it creates the object then calls `self.add(new_obj, through_defaults=...)` to write the through row.
- `django/db/models/fields/related_descriptors.py:create_forward_many_to_many_manager.ManyRelatedManager.get_or_create` — sync M2M get_or_create that adds the through row when created; the inherited `aget_or_create()` skips that.
- `django/db/models/fields/related_descriptors.py:create_forward_many_to_many_manager.ManyRelatedManager.update_or_create` — sync M2M update_or_create that adds the through row when created; the inherited `aupdate_or_create()` skips that.

## Where the leaked async methods come from

- `django/db/models/query.py:QuerySet.acreate` — the async QuerySet create that related managers inherit; it wraps `self.create` (the QuerySet's own create), so it has no knowledge of the relation.
- `django/db/models/query.py:QuerySet.aget_or_create` — the async QuerySet get_or_create inherited by related managers; wraps the QuerySet's `get_or_create`, bypassing the related manager's FK/through handling.
- `django/db/models/query.py:QuerySet.aupdate_or_create` — the async QuerySet update_or_create inherited by related managers; wraps the QuerySet's `update_or_create`, bypassing the related manager's FK/through handling.
- `django/db/models/query.py:QuerySet.create` — the sync QuerySet create that the inherited async methods end up calling, which does not inject the related field or through row.
- `django/db/models/query.py:QuerySet.get_or_create` — the sync QuerySet get_or_create that the inherited async method ends up calling, without relation handling.
- `django/db/models/query.py:QuerySet.update_or_create` — the sync QuerySet update_or_create that the inherited async method ends up calling, without relation handling.
- `django/db/models/manager.py:BaseManager._get_queryset_methods` — copies every public QuerySet method (including `acreate`, `aget_or_create`, `aupdate_or_create`) onto managers, which is how the async methods reach related managers in the first place.
- `django/db/models/manager.py:Manager` — the concrete manager built via `BaseManager.from_queryset(QuerySet)`, so it carries the proxied async methods that related managers inherit.

## Sibling related managers doing the same thing the same way

- `django/contrib/contenttypes/fields.py:create_generic_related_manager.GenericRelatedObjectManager.create` — the generic-relation sync create that injects content type/object id; it has no async counterpart, so `acreate()` inherited from the QuerySet bypasses this injection the same way.
- `django/contrib/contenttypes/fields.py:create_generic_related_manager.GenericRelatedObjectManager.get_or_create` — generic-relation sync get_or_create injecting content type/object id; inherited `aget_or_create()` bypasses it.
- `django/contrib/contenttypes/fields.py:create_generic_related_manager.GenericRelatedObjectManager.update_or_create` — generic-relation sync update_or_create injecting content type/object id; inherited `aupdate_or_create()` bypasses it.
- `django/contrib/contenttypes/fields.py:ReverseGenericManyToOneDescriptor.related_manager_cls` — builds the generic related manager class from the related model's default manager, so it inherits the same leaked async QuerySet methods.
- `django/db/models/fields/related_descriptors.py:ReverseManyToOneDescriptor.related_manager_cls` — builds the reverse-FK related manager from the related model's default manager, the entry point through which the leaked async methods are exposed.
- `django/db/models/fields/related_descriptors.py:ManyToManyDescriptor.related_manager_cls` — builds the M2M related manager (forward and reverse) from the related model's default manager, exposing the same leaked async methods.
