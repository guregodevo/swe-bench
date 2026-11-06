# pydata__xarray-3095 — memdoor team-solve

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 305s 84 lines cost=0.008659 in=491606 cached=450560 out=14885 calls=30`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `direct` (agent)

**user**

````
Workflow team-solve, task direct.

REGRESSION: copy(deep=True) casts unicode indices to object
Dataset.copy(deep=True) and DataArray.copy (deep=True/False) accidentally cast IndexVariable's with dtype='<U*' to object. Same applies to copy.copy() and copy.deepcopy().

This is a regression in xarray >= 0.12.2. xarray 0.12.1 and earlier are unaffected.

```

In [1]: ds = xarray.Dataset(
   ...:     coords={'x': ['foo'], 'y': ('x', ['bar'])},
   ...:     data_vars={'z': ('x', ['baz'])})                                                              

In [2]: ds                                                                                                                                                                                                                     
Out[2]: 
<xarray.Dataset>
Dimensions:  (x: 1)
Coordinates:
  * x        (x) <U3 'foo'
    y        (x) <U3 'bar'
Data variables:
    z        (x) <U3 'baz'

In [3]: ds.copy()                                                                                                                                                                                                              
Out[3]: 
<xarray.Dataset>
Dimensions:  (x: 1)
Coordinates:
  * x        (x) <U3 'foo'
    y        (x) <U3 'bar'
Data variables:
    z        (x) <U3 'baz'

In [4]: ds.copy(deep=True)                                                                                                                                                                                                     
Out[4]: 
<xarray.Dataset>
Dimensions:  (x: 1)
Coordinates:
  * x        (x) object 'foo'
    y        (x) <U3 'bar'
Data variables:
    z        (x) <U3 'baz'

In [5]: ds.z                                                                                                                                                                                                                   
Out[5]: 
<xarray.DataArray 'z' (x: 1)>
array(['baz'], dtype='<U3')
Coordinates:
  * x        (x) <U3 'foo'
    y        (x) <U3 'bar'

In [6]: ds.z.copy()                                                                                                                                                                                                            
Out[6]: 
<xarray.DataArray 'z' (x: 1)>
array(['baz'], dtype='<U3')
Coordinates:
  * x        (x) object 'foo'
    y        (x) <U3 'bar'

In [7]: ds.z.copy(deep=True)                                                                                                                                                                                                   
Out[7]: 
<xarray.DataArray 'z' (x: 1)>
array(['baz'], dtype='<U3')
Coordinates:
  * x        (x) object 'foo'
    y        (x) <U3 'bar'
```


Do not commit, check out, reset or stash: the tree's HEAD stays where it is. Write what the task asks for as soon as you have a first version, then improve it: a turn that ends without it has done nothing. Keep no rule with the notes tool (it writes the project's AGENTS.md), and leave .memdoor/ alone.

Your answer is kept as this task's result; the tasks after it read it.
````

**assistant → tool `bash`**

```json
{
  "command": "ls && git log --oneline -3 && git status --short"
}
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"def copy\" xarray/core/indexing.py xarray/core/variable.py xarray/core/dataset.py xarray/core/dataarray.py | head -50"
}
```

**tool result**

```
CODE_OF_CONDUCT.md
HOW_TO_RELEASE
LICENSE
MANIFEST.in
README.rst
__pycache__
asv_bench
azure-pipelines.yml
ci
conftest.py
doc
examples
licenses
properties
readthedocs.yml
setup.cfg
setup.py
versioneer.py
xarray
xarray.egg-info
779ee654 SWE-bench
1757dffa More annotations in Dataset (#3112)
e5205347 Hotfix for case of combining identical non-monotonic coords (#3151)
?? .memdoor/
```

**tool result**

```
xarray/core/variable.py:743:    def copy(self, deep=True, data=None):
xarray/core/variable.py:1920:    def copy(self, deep=True, data=None):
xarray/core/dataset.py:842:    def copy(self, deep: bool = False, data: Mapping = None) -> 'Dataset':
xarray/core/dataarray.py:777:    def copy(
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n 700,800p xarray/core/variable.py; echo ====; sed -n 1880,1960p xarray/core/variable.py"
}
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"class IndexVariable\" -A 120 xarray/core/variable.py | head -160"
}
```

**tool result**

```
                value = Variable((), value)
            else:
                value = Variable(dims[-value.ndim:], value)
        # broadcast to become assignable
        value = value.set_dims(dims).data

        if new_order:
            value = duck_array_ops.asarray(value)
            value = value[(len(dims) - value.ndim) * (np.newaxis,) +
                          (Ellipsis,)]
            value = duck_array_ops.moveaxis(
                value, new_order, range(len(new_order)))

        indexable = as_indexable(self._data)
        indexable[index_tuple] = value

    @property
    def attrs(self) -> 'OrderedDict[Any, Any]':
        """Dictionary of local attributes on this variable.
        """
        if self._attrs is None:
            self._attrs = OrderedDict()
        return self._attrs

    @attrs.setter
    def attrs(self, value: Mapping[Hashable, Any]) -> None:
        self._attrs = OrderedDict(value)

    @property
    def encoding(self):
        """Dictionary of encodings on this variable.
        """
        if self._encoding is None:
            self._encoding = {}
        return self._encoding

    @encoding.setter
    def encoding(self, value):
        try:
            self._encoding = dict(value)
        except ValueError:
            raise ValueError('encoding must be castable to a dictionary')

    def copy(self, deep=True, data=None):
        """Returns a copy of this object.

        If `deep=True`, the data array is loaded into memory and copied onto
        the new object. Dimensions, attributes and encodings are always copied.

        Use `data` to create a new object with the same structure as
        original but entirely new data.

        Parameters
        ----------
        deep : bool, optional
            Whether the data array is loaded into memory and copied onto
            the new object. Default is True.
        data : array_like, optional
            Data to use in the new object. Must have same shape as original.
            When `data` is used, `deep` is ignored.

        Returns
        -------
        object : Variable
            New object with dimensions, attributes, encodings, and optionally
            data copied from original.

        Examples
        --------

        Shallow copy versus deep copy

        >>> var = xr.Variable(data=[1, 2, 3], dims='x')
        >>> var.copy()
        <xarray.Variable (x: 3)>
        array([1, 2, 3])
        >>> var_0 = var.copy(deep=False)
        >>> var_0[0] = 7
        >>> var_0
        <xarray.Variable (x: 3)>
        array([7, 2, 3])
        >>> var
        <xarray.Variable (x: 3)>
        array([7, 2, 3])

        Changing the data using the ``data`` argument maintains the
        structure of the original object, but with the new data. Original
        object is unaffected.

        >>> var.copy(data=[0.1, 0.2, 0.3])
        <xarray.Variable (x: 3)>
        array([ 0.1,  0.2,  0.3])
        >>> var
        <xarray.Variable (x: 3)>
        array([7, 2, 3])

        See Also
        --------
        pandas.DataFrame.copy
        """
        if data is None:
====

    @classmethod
    def concat(cls, variables, dim='concat_dim', positions=None,
               shortcut=False):
        """Specialized version of Variable.concat for IndexVariable objects.

        This exists because we want to avoid converting Index objects to NumPy
        arrays, if possible.
        """
        if not isinstance(dim, str):
            dim, = dim.dims

        variables = list(variables)
        first_var = variables[0]

        if any(not isinstance(v, cls) for v in variables):
            raise TypeError('IndexVariable.concat requires that all input '
                            'variables be IndexVariable objects')

        indexes = [v._data.array for v in variables]

        if not indexes:
            data = []
        else:
            data = indexes[0].append(indexes[1:])

            if positions is not None:
                indices = nputils.inverse_permutation(
                    np.concatenate(positions))
                data = data.take(indices)

        attrs = OrderedDict(first_var.attrs)
        if not shortcut:
            for var in variables:
                if var.dims != first_var.dims:
                    raise ValueError('inconsistent dimensions')
                utils.remove_incompatible_items(attrs, var.attrs)

        return cls(first_var.dims, data, attrs)

    def copy(self, deep=True, data=None):
        """Returns a copy of this object.

        `deep` is ignored since data is stored in the form of
        pandas.Index, which is already immutable. Dimensions, attributes
        and encodings are always copied.

        Use `data` to create a new object with the same structure as
        original but entirely new data.

        Parameters
        ----------
        deep : bool, optional
            Deep is ignored when data is given. Whether the data array is
            loaded into memory and copied onto the new object. Default is True.
        data : array_like, optional
            Data to use in the new object. Must have same shape as original.

        Returns
        -------
        object : Variable
            New object with dimensions, attributes, encodings, and optionally
            data copied from original.
        """
        if data is None:
            if deep:
                # self._data should be a `PandasIndexAdapter` instance at this
                # point, which doesn't have a copy method, so make a deep copy
                # of the underlying `pandas.MultiIndex` and create a new
                # `PandasIndexAdapter` instance with it.
                data = PandasIndexAdapter(self._data.array.copy(deep=True))
            else:
                data = self._data
        else:
            data = as_compatible_data(data)
            if self.shape != data.shape:
                raise ValueError("Data shape {} must match shape of object {}"
                                 .format(data.shape, self.shape))
        return type(self)(self.dims, data, self._attrs,
                          self._encoding, fastpath=True)
```

**tool result**

```
1834:class IndexVariable(Variable):
1835-    """Wrapper for accommodating a pandas.Index in an xarray.Variable.
1836-
1837-    IndexVariable preserve loaded values in the form of a pandas.Index instead
1838-    of a NumPy array. Hence, their values are immutable and must always be one-
1839-    dimensional.
1840-
1841-    They also have a name property, which is the name of their sole dimension
1842-    unless another name is given.
1843-    """
1844-
1845-    def __init__(self, dims, data, attrs=None, encoding=None, fastpath=False):
1846-        super().__init__(dims, data, attrs, encoding, fastpath)
1847-        if self.ndim != 1:
1848-            raise ValueError('%s objects must be 1-dimensional' %
1849-                             type(self).__name__)
1850-
1851-        # Unlike in Variable, always eagerly load values into memory
1852-        if not isinstance(self._data, PandasIndexAdapter):
1853-            self._data = PandasIndexAdapter(self._data)
1854-
1855-    def load(self):
1856-        # data is already loaded into memory for IndexVariable
1857-        return self
1858-
1859-    # https://github.com/python/mypy/issues/1465
1860-    @Variable.data.setter  # type: ignore
1861-    def data(self, data):
1862-        Variable.data.fset(self, data)
1863-        if not isinstance(self._data, PandasIndexAdapter):
1864-            self._data = PandasIndexAdapter(self._data)
1865-
1866-    def chunk(self, chunks=None, name=None, lock=False):
1867-        # Dummy - do not chunk. This method is invoked e.g. by Dataset.chunk()
1868-        return self.copy(deep=False)
1869-
1870-    def _finalize_indexing_result(self, dims, data):
1871-        if getattr(data, 'ndim', 0) != 1:
1872-            # returns Variable rather than IndexVariable if multi-dimensional
1873-            return Variable(dims, data, self._attrs, self._encoding)
1874-        else:
1875-            return type(self)(dims, data, self._attrs,
1876-                              self._encoding, fastpath=True)
1877-
1878-    def __setitem__(self, key, value):
1879-        raise TypeError('%s values cannot be modified' % type(self).__name__)
1880-
1881-    @classmethod
1882-    def concat(cls, variables, dim='concat_dim', positions=None,
1883-               shortcut=False):
1884-        """Specialized version of Variable.concat for IndexVariable objects.
1885-
1886-        This exists because we want to avoid converting Index objects to NumPy
1887-        arrays, if possible.
1888-        """
1889-        if not isinstance(dim, str):
1890-            dim, = dim.dims
1891-
1892-        variables = list(variables)
1893-        first_var = variables[0]
1894-
1895-        if any(not isinstance(v, cls) for v in variables):
1896-            raise TypeError('IndexVariable.concat requires that all input '
1897-                            'variables be IndexVariable objects')
1898-
1899-        indexes = [v._data.array for v in variables]
1900-
1901-        if not indexes:
1902-            data = []
1903-        else:
1904-            data = indexes[0].append(indexes[1:])
1905-
1906-            if positions is not None:
1907-                indices = nputils.inverse_permutation(
1908-                    np.concatenate(positions))
1909-                data = data.take(indices)
1910-
1911-        attrs = OrderedDict(first_var.attrs)
1912-        if not shortcut:
1913-            for var in variables:
1914-                if var.dims != first_var.dims:
1915-                    raise ValueError('inconsistent dimensions')
1916-                utils.remove_incompatible_items(attrs, var.attrs)
1917-
1918-        return cls(first_var.dims, data, attrs)
1919-
1920-    def copy(self, deep=True, data=None):
1921-        """Returns a copy of this object.
1922-
1923-        `deep` is ignored since data is stored in the form of
1924-        pandas.Index, which is already immutable. Dimensions, attributes
1925-        and encodings are always copied.
1926-
1927-        Use `data` to create a new object with the same structure as
1928-        original but entirely new data.
1929-
1930-        Parameters
1931-        ----------
1932-        deep : bool, optional
1933-            Deep is ignored when data is given. Whether the data array is
1934-            loaded into memory and copied onto the new object. Default is True.
1935-        data : array_like, optional
1936-            Data to use in the new object. Must have same shape as original.
1937-
1938-        Returns
1939-        -------
1940-        object : Variable
1941-            New object with dimensions, attributes, encodings, and optionally
1942-            data copied from original.
1943-        """
1944-        if data is None:
1945-            if deep:
1946-                # self._data should be a `PandasIndexAdapter` instance at this
1947-                # point, which doesn't have a copy method, so make a deep copy
1948-                # of the underlying `pandas.MultiIndex` and create a new
1949-                # `PandasIndexAdapter` instance with it.
1950-                data = PandasIndexAdapter(self._data.array.copy(deep=True))
1951-            else:
1952-                data = self._data
1953-        else:
1954-            data = as_compatible_data(data)
```

**assistant → tool `bash`**

```json
{
  "command": "python -c \"\nimport pandas as pd, numpy as np\ni=pd.Index(np.array(['foo'],dtype='<U3'))\nprint(i.dtype, i.copy(deep=True).dtype, i.copy(deep=False).dtype)\nprint(pd.__version__)\n\""
}
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"class PandasIndexAdapter\" -A 100 xarray/core/indexing.py"
}
```

**tool result**

```
object object object
1.5.3
```

**tool result**

```
1229:class PandasIndexAdapter(ExplicitlyIndexedNDArrayMixin):
1230-    """Wrap a pandas.Index to preserve dtypes and handle explicit indexing."""
1231-
1232-    def __init__(self, array, dtype=None):
1233-        self.array = utils.safe_cast_to_index(array)
1234-        if dtype is None:
1235-            if isinstance(array, pd.PeriodIndex):
1236-                dtype = np.dtype('O')
1237-            elif hasattr(array, 'categories'):
1238-                # category isn't a real numpy dtype
1239-                dtype = array.categories.dtype
1240-            elif not utils.is_valid_numpy_dtype(array.dtype):
1241-                dtype = np.dtype('O')
1242-            else:
1243-                dtype = array.dtype
1244-        self._dtype = dtype
1245-
1246-    @property
1247-    def dtype(self):
1248-        return self._dtype
1249-
1250-    def __array__(self, dtype=None):
1251-        if dtype is None:
1252-            dtype = self.dtype
1253-        array = self.array
1254-        if isinstance(array, pd.PeriodIndex):
1255-            with suppress(AttributeError):
1256-                # this might not be public API
1257-                array = array.astype('object')
1258-        return np.asarray(array.values, dtype=dtype)
1259-
1260-    @property
1261-    def shape(self):
1262-        # .shape is broken on pandas prior to v0.15.2
1263-        return (len(self.array),)
1264-
1265-    def __getitem__(self, indexer):
1266-        key = indexer.tuple
1267-        if isinstance(key, tuple) and len(key) == 1:
1268-            # unpack key so it can index a pandas.Index object (pandas.Index
1269-            # objects don't like tuples)
1270-            key, = key
1271-
1272-        if getattr(key, 'ndim', 0) > 1:  # Return np-array if multidimensional
1273-            return NumpyIndexingAdapter(self.array.values)[indexer]
1274-
1275-        result = self.array[key]
1276-
1277-        if isinstance(result, pd.Index):
1278-            result = PandasIndexAdapter(result, dtype=self.dtype)
1279-        else:
1280-            # result is a scalar
1281-            if result is pd.NaT:
1282-                # work around the impossibility of casting NaT with asarray
1283-                # note: it probably would be better in general to return
1284-                # pd.Timestamp rather np.than datetime64 but this is easier
1285-                # (for now)
1286-                result = np.datetime64('NaT', 'ns')
1287-            elif isinstance(result, timedelta):
1288-                result = np.timedelta64(getattr(result, 'value', result), 'ns')
1289-            elif isinstance(result, pd.Timestamp):
1290-                # Work around for GH: pydata/xarray#1932 and numpy/numpy#10668
1291-                # numpy fails to convert pd.Timestamp to np.datetime64[ns]
1292-                result = np.asarray(result.to_datetime64())
1293-            elif self.dtype != object:
1294-                result = np.asarray(result, dtype=self.dtype)
1295-
1296-            # as for numpy.ndarray indexing, we always want the result to be
1297-            # a NumPy array.
1298-            result = utils.to_0d_array(result)
1299-
1300-        return result
1301-
1302-    def transpose(self, order):
1303-        return self.array  # self.array should be always one-dimensional
1304-
1305-    def __repr__(self):
1306-        return ('%s(array=%r, dtype=%r)'
1307-                % (type(self).__name__, self.array, self.dtype))
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n 777,900p xarray/core/dataarray.py; sed -n 842,940p xarray/core/dataset.py"
}
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"PandasIndexAdapter(\" xarray/core | head -40"
}
```

**tool result**

```
    def copy(
        self,
        deep: bool = True,
        data: Any = None,
    ) -> 'DataArray':
        """Returns a copy of this array.

        If `deep=True`, a deep copy is made of the data array.
        Otherwise, a shallow copy is made, so each variable in the new
        array's dataset is also a variable in this array's dataset.

        Use `data` to create a new object with the same structure as
        original but entirely new data.

        Parameters
        ----------
        deep : bool, optional
            Whether the data array and its coordinates are loaded into memory
            and copied onto the new object. Default is True.
        data : array_like, optional
            Data to use in the new object. Must have same shape as original.
            When `data` is used, `deep` is ignored for all data variables,
            and only used for coords.

        Returns
        -------
        object : DataArray
            New object with dimensions, attributes, coordinates, name,
            encoding, and optionally data copied from original.

        Examples
        --------

        Shallow versus deep copy

        >>> array = xr.DataArray([1, 2, 3], dims='x',
        ...                      coords={'x': ['a', 'b', 'c']})
        >>> array.copy()
        <xarray.DataArray (x: 3)>
        array([1, 2, 3])
        Coordinates:
        * x        (x) <U1 'a' 'b' 'c'
        >>> array_0 = array.copy(deep=False)
        >>> array_0[0] = 7
        >>> array_0
        <xarray.DataArray (x: 3)>
        array([7, 2, 3])
        Coordinates:
        * x        (x) <U1 'a' 'b' 'c'
        >>> array
        <xarray.DataArray (x: 3)>
        array([7, 2, 3])
        Coordinates:
        * x        (x) <U1 'a' 'b' 'c'

        Changing the data using the ``data`` argument maintains the
        structure of the original object, but with the new data. Original
        object is unaffected.

        >>> array.copy(data=[0.1, 0.2, 0.3])
        <xarray.DataArray (x: 3)>
        array([ 0.1,  0.2,  0.3])
        Coordinates:
        * x        (x) <U1 'a' 'b' 'c'
        >>> array
        <xarray.DataArray (x: 3)>
        array([1, 2, 3])
        Coordinates:
        * x        (x) <U1 'a' 'b' 'c'

        See also
        --------
        pandas.DataFrame.copy
        """
        variable = self.variable.copy(deep=deep, data=data)
        coords = OrderedDict((k, v.copy(deep=deep))
                             for k, v in self._coords.items())
        return self._replace(variable, coords)

    def __copy__(self) -> 'DataArray':
        return self.copy(deep=False)

    def __deepcopy__(self, memo=None) -> 'DataArray':
        # memo does nothing but is required for compatibility with
        # copy.deepcopy
        return self.copy(deep=True)

    # mutable objects should not be hashable
    # https://github.com/python/mypy/issues/4266
    __hash__ = None  # type: ignore

    @property
    def chunks(self) -> Optional[Tuple[Tuple[int, ...], ...]]:
        """Block dimensions for this array's data or None if it's not a dask
        array.
        """
        return self.variable.chunks

    def chunk(
        self,
        chunks: Union[
            None,
            Number,
            Tuple[Number, ...],
            Tuple[Tuple[Number, ...], ...],
            Mapping[Hashable, Union[None, Number, Tuple[Number, ...]]],
        ] = None,
        name_prefix: str = 'xarray-',
        token: str = None,
        lock: bool = False
    ) -> 'DataArray':
        """Coerce this array's data into a dask arrays with the given chunks.

        If this variable is a non-dask array, it will be converted to dask
        array. If it's a dask array, it will be rechunked to the given chunk
        sizes.

        If neither chunks is not provided for one or more dimensions, chunk
        sizes along that dimension will not be updated; non-dask arrays will be
        converted into dask arrays with a single block.

        Parameters
        ----------
        chunks : int, tuple or mapping, optional
    def copy(self, deep: bool = False, data: Mapping = None) -> 'Dataset':
        """Returns a copy of this dataset.

        If `deep=True`, a deep copy is made of each of the component variables.
        Otherwise, a shallow copy of each of the component variable is made, so
        that the underlying memory region of the new dataset is the same as in
        the original dataset.

        Use `data` to create a new object with the same structure as
        original but entirely new data.

        Parameters
        ----------
        deep : bool, optional
            Whether each component variable is loaded into memory and copied onto
            the new object. Default is False.
        data : dict-like, optional
            Data to use in the new object. Each item in `data` must have same
            shape as corresponding data variable in original. When `data` is
            used, `deep` is ignored for the data variables and only used for
            coords.

        Returns
        -------
        object : Dataset
            New object with dimensions, attributes, coordinates, name, encoding,
            and optionally data copied from original.

        Examples
        --------

        Shallow copy versus deep copy

        >>> da = xr.DataArray(np.random.randn(2, 3))
        >>> ds = xr.Dataset({'foo': da, 'bar': ('x', [-1, 2])},
                            coords={'x': ['one', 'two']})
        >>> ds.copy()
        <xarray.Dataset>
        Dimensions:  (dim_0: 2, dim_1: 3, x: 2)
        Coordinates:
        * x        (x) <U3 'one' 'two'
        Dimensions without coordinates: dim_0, dim_1
        Data variables:
            foo      (dim_0, dim_1) float64 -0.8079 0.3897 -1.862 -0.6091 -1.051 -0.3003
            bar      (x) int64 -1 2
        >>> ds_0 = ds.copy(deep=False)
        >>> ds_0['foo'][0, 0] = 7
        >>> ds_0
        <xarray.Dataset>
        Dimensions:  (dim_0: 2, dim_1: 3, x: 2)
        Coordinates:
        * x        (x) <U3 'one' 'two'
        Dimensions without coordinates: dim_0, dim_1
        Data variables:
            foo      (dim_0, dim_1) float64 7.0 0.3897 -1.862 -0.6091 -1.051 -0.3003
            bar      (x) int64 -1 2
        >>> ds
        <xarray.Dataset>
        Dimensions:  (dim_0: 2, dim_1: 3, x: 2)
        Coordinates:
        * x        (x) <U3 'one' 'two'
        Dimensions without coordinates: dim_0, dim_1
        Data variables:
            foo      (dim_0, dim_1) float64 7.0 0.3897 -1.862 -0.6091 -1.051 -0.3003
            bar      (x) int64 -1 2

        Changing the data using the ``data`` argument maintains the
        structure of the original object, but with the new data. Original
        object is unaffected.

        >>> ds.copy(data={'foo': np.arange(6).reshape(2, 3), 'bar': ['a', 'b']})
        <xarray.Dataset>
        Dimensions:  (dim_0: 2, dim_1: 3, x: 2)
        Coordinates:
        * x        (x) <U3 'one' 'two'
        Dimensions without coordinates: dim_0, dim_1
        Data variables:
            foo      (dim_0, dim_1) int64 0 1 2 3 4 5
            bar      (x) <U1 'a' 'b'
        >>> ds
        <xarray.Dataset>
        Dimensions:  (dim_0: 2, dim_1: 3, x: 2)
        Coordinates:
        * x        (x) <U3 'one' 'two'
        Dimensions without coordinates: dim_0, dim_1
        Data variables:
            foo      (dim_0, dim_1) float64 7.0 0.3897 -1.862 -0.6091 -1.051 -0.3003
            bar      (x) int64 -1 2

        See Also
        --------
        pandas.DataFrame.copy
        """  # noqa
        if data is None:
            variables = OrderedDict((k, v.copy(deep=deep))
                                    for k, v in self._variables.items())
        elif not utils.is_dict_like(data):
            raise ValueError('Data must be dict-like')
        else:
```

**tool result**

```
xarray/core/variable.py:128:        return PandasIndexAdapter(data)
xarray/core/variable.py:1853:            self._data = PandasIndexAdapter(self._data)
xarray/core/variable.py:1864:            self._data = PandasIndexAdapter(self._data)
xarray/core/variable.py:1950:                data = PandasIndexAdapter(self._data.array.copy(deep=True))
xarray/core/indexing.py:656:        return PandasIndexAdapter(array)
xarray/core/indexing.py:1229:class PandasIndexAdapter(ExplicitlyIndexedNDArrayMixin):
xarray/core/indexing.py:1278:            result = PandasIndexAdapter(result, dtype=self.dtype)
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"def safe_cast_to_index\" -A 40 xarray/core/utils.py; sed -n 100,140p xarray/core/variable.py"
}
```

**assistant → tool `bash`**

```json
{
  "command": "python -c \"\nimport pandas as pd, numpy as np\na=np.array(['foo'],dtype='<U3')\ni=pd.Index(a)\nprint(i.dtype, i.values.dtype)\nprint(pd.Index(a).copy(deep=True).dtype)\n\""
}
```

**tool result**

```
69:def safe_cast_to_index(array: Any) -> pd.Index:
70-    """Given an array, safely cast it to a pandas.Index.
71-
72-    If it is already a pandas.Index, return it unchanged.
73-
74-    Unlike pandas.Index, if the array has dtype=object or dtype=timedelta64,
75-    this function will not attempt to do automatic type conversion but will
76-    always return an index with dtype=object.
77-    """
78-    if isinstance(array, pd.Index):
79-        index = array
80-    elif hasattr(array, 'to_index'):
81-        index = array.to_index()
82-    else:
83-        kwargs = {}
84-        if hasattr(array, 'dtype') and array.dtype.kind == 'O':
85-            kwargs['dtype'] = object
86-        index = pd.Index(np.asarray(array), **kwargs)
87-    return _maybe_cast_to_cftimeindex(index)
88-
89-
90-def multiindex_from_product_levels(levels: Sequence[pd.Index],
91-                                   names: Sequence[str] = None
92-                                   ) -> pd.MultiIndex:
93-    """Creating a MultiIndex from a product without refactorizing levels.
94-
95-    Keeping levels the same gives back the original labels when we unstack.
96-
97-    Parameters
98-    ----------
99-    levels : sequence of pd.Index
100-        Values for each MultiIndex level.
101-    names : optional sequence of objects
102-        Names for each level.
103-
104-    Returns
105-    -------
106-    pandas.MultiIndex
107-    """
108-    if any(not isinstance(lev, pd.Index) for lev in levels):
109-        raise TypeError('levels must be a list of pd.Index objects')
                '(dims, data) instead.' % (name, data.ndim))
        obj = Variable(name, data, fastpath=True)
    else:
        raise TypeError('unable to convert object into a variable without an '
                        'explicit list of dimensions: %r' % obj)

    if name is not None and name in obj.dims:
        # convert the Variable into an Index
        if obj.ndim != 1:
            raise MissingDimensionsError(
                '%r has more than 1-dimension and the same name as one of its '
                'dimensions %r. xarray disallows such variables because they '
                'conflict with the coordinates used to label '
                'dimensions.' % (name, obj.dims))
        obj = obj.to_index_variable()

    return obj


def _maybe_wrap_data(data):
    """
    Put pandas.Index and numpy.ndarray arguments in adapter objects to ensure
    they can be indexed properly.

    NumpyArrayAdapter, PandasIndexAdapter and LazilyOuterIndexedArray should
    all pass through unmodified.
    """
    if isinstance(data, pd.Index):
        return PandasIndexAdapter(data)
    return data


def _possibly_convert_objects(values):
    """Convert arrays of datetime.datetime and datetime.timedelta objects into
    datetime64 and timedelta64, according to the pandas convention.
    """
    return np.asarray(pd.Series(values.ravel())).reshape(values.shape)


def as_compatible_data(data, fastpath=False):
    """Prepare and wrap data to put in a Variable.
```

**tool result**

```
object object
object
```

**assistant → tool `bash`**

```json
{
  "command": "python -c \"\nimport xarray as xr\nds=xr.Dataset(coords={'x':['foo'],'y':('x',['bar'])},data_vars={'z':('x',['baz'])})\nprint(ds)\nprint(ds.x.variable._data, ds.x.variable._data.dtype)\nprint(ds.copy(deep=True))\nprint(ds.copy(deep=True).x.variable._data.dtype)\n\""
}
```

**tool result**

```
/testbed/xarray/plot/plot.py:243: SyntaxWarning: "is" with a literal. Did you mean "=="?
  if args is ():
<xarray.Dataset>
Dimensions:  (x: 1)
Coordinates:
  * x        (x) <U3 'foo'
    y        (x) <U3 'bar'
Data variables:
    z        (x) <U3 'baz'
PandasIndexAdapter(array=Index(['foo'], dtype='object'), dtype=dtype('<U3')) <U3
<xarray.Dataset>
Dimensions:  (x: 1)
Coordinates:
  * x        (x) object 'foo'
    y        (x) <U3 'bar'
Data variables:
    z        (x) <U3 'baz'
object
```

**assistant → tool `bash`**

```json
{
  "command": "python -c \"\nimport xarray as xr\nds=xr.Dataset(coords={'x':['foo'],'y':('x',['bar'])},data_vars={'z':('x',['baz'])})\nfor d in [False,True]:\n print(d, ds.z.copy(deep=d).x.variable._data.dtype, ds.copy(deep=d).x.variable._data.dtype)\n\""
}
```

**tool result**

```
False <U3 <U3
True object object
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"copy(deep\" xarray/tests/test_dataset.py xarray/tests/test_dataarray.py xarray/tests/test_variable.py | head -30; grep -rn \"unicode\\|<U\\|dtype.*copy\\|copy.*dtype\" xarray/tests/test_* | head -30"
}
```

**tool result**

```
xarray/tests/test_dataset.py:616:        actual = data.copy(deep=True)
xarray/tests/test_dataset.py:620:        actual = data.copy(deep=True)
xarray/tests/test_dataset.py:624:        actual = data.copy(deep=True)
xarray/tests/test_dataset.py:640:        actual = data.copy(deep=True)
xarray/tests/test_dataset.py:1586:        expected = data.copy(deep=True)
xarray/tests/test_dataset.py:1746:        right = left.copy(deep=True)
xarray/tests/test_dataset.py:2047:        for copied in [data.copy(deep=False), copy(data)]:
xarray/tests/test_dataset.py:2064:        for copied in [data.copy(deep=True), deepcopy(data)]:
xarray/tests/test_dataset.py:2100:        ds_cp = ds.copy(deep=deep)
xarray/tests/test_dataset.py:3728:        expected = ds.copy(deep=True)
xarray/tests/test_dataset.py:3742:        expected = ds.copy(deep=True)
xarray/tests/test_dataset.py:4167:        actual = ds.copy(deep=True)
xarray/tests/test_dataset.py:4198:        actual = ds.copy(deep=True)
xarray/tests/test_dataset.py:4204:        actual = ds.copy(deep=True)
xarray/tests/test_dataset.py:4224:        actual = ds.copy(deep=True)
xarray/tests/test_dataset.py:4261:        actual = ds.copy(deep=True)
xarray/tests/test_dataset.py:4281:        actual = ds.copy(deep=True)
xarray/tests/test_dataset.py:4568:        expect = ds.copy(deep=True)
xarray/tests/test_dataset.py:4577:        expect = ds.copy(deep=True)
xarray/tests/test_dataarray.py:3473:        da_cp = da.copy(deep)
xarray/tests/test_dataarray.py:3506:        expect = da.copy(deep=True)
xarray/tests/test_variable.py:402:                       expected.copy(deep=True),
xarray/tests/test_variable.py:403:                       expected.copy(deep=False)]:
xarray/tests/test_variable.py:482:        w = v.copy(deep=deep)
xarray/tests/test_variable.py:500:            w = v.copy(deep=deep)
xarray/tests/test_variable.py:576:        copied = array.copy(deep=True)
xarray/tests/test_variable.py:1994:        expect = orig.copy(deep=True)
xarray/tests/test_accessor_str.py:154:def test_replace_unicode():
xarray/tests/test_accessor_str.py:155:    # flags + unicode
xarray/tests/test_accessor_str.py:600:    # test with pre and post whitespace (non-unicode), NaN, and non-ascii
xarray/tests/test_backends.py:2096:        # unicode instead of leaving them as bytes.
xarray/tests/test_backends.py:2107:    def test_read_byte_attrs_as_unicode(self):
xarray/tests/test_backends.py:2982:            # netcdf converts string to byte not unicode
xarray/tests/test_coding_strings.py:22:    assert strings.is_unicode_dtype(dtype)
xarray/tests/test_coding_strings.py:28:    assert not strings.is_unicode_dtype(dtype)
xarray/tests/test_coding_strings.py:72:    coder = strings.EncodedStringCoder(allows_unicode=True)
xarray/tests/test_coding_strings.py:81:    coder = strings.EncodedStringCoder(allows_unicode=False)
xarray/tests/test_conventions.py:250:        coder = coding.strings.EncodedStringCoder(allows_unicode=True)
xarray/tests/test_dataarray.py:3147:        endiantype = '<U1' if sys.byteorder == 'little' else '>U1'
xarray/tests/test_dataset.py:66:    unicode_var = ["áó", "áó", "áó"]
xarray/tests/test_dataset.py:74:            'unicode_var': xr.DataArray(unicode_var, coords=[time1],
xarray/tests/test_dataset.py:75:                                        dims=['time']).astype(np.unicode_)
xarray/tests/test_dataset.py:85:            'unicode_var': xr.DataArray(unicode_var[:nt2], coords=[time2],
xarray/tests/test_dataset.py:86:                                        dims=['time']).astype(np.unicode_)
xarray/tests/test_dataset.py:236:    def test_unicode_data(self):
xarray/tests/test_dataset.py:257:        ds.attrs['unicode_attr'] = 'ba®'
xarray/tests/test_dataset.py:283:        \t:unicode_attr = ba® ;
xarray/tests/test_dataset.py:3428:        #   * t        (t) <U1 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j'
xarray/tests/test_dataset.py:3463:        endiantype = '<U1' if sys.byteorder == 'little' else '>U1'
xarray/tests/test_dataset.py:4876:def test_dir_unicode(data_set):
xarray/tests/test_dataset.py:4877:    data_set['unicode'] = 'uni'
xarray/tests/test_dataset.py:4879:    assert 'unicode' in result
xarray/tests/test_dtypes.py:12:    ([np.unicode_, np.int64], np.object_),
xarray/tests/test_dtypes.py:13:    ([np.unicode_, np.unicode_], np.unicode_),
xarray/tests/test_dtypes.py:14:    ([np.bytes_, np.unicode_], np.object_),
xarray/tests/test_dtypes.py:77:    ('U', (np.dtype('O'), 'nan')),  # dtype('<U')
xarray/tests/test_variable.py:1170:        v = Variable([], np.unicode_('asdf'))
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: xarray/core/variable.py\n@@\n-                data = PandasIndexAdapter(self._data.array.copy(deep=True))\n+                data = PandasIndexAdapter(self._data.array.copy(deep=True),\n+                                          dtype=self._data.dtype)\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[xarray/core/variable.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

xarray/core/variable.py now (2161 lines), around the change:
1947:                # point, which doesn't have a copy method, so make a deep copy
1948:                # of the underlying `pandas.MultiIndex` and create a new
1949:                # `PandasIndexAdapter` instance with it.
1950:                data = PandasIndexAdapter(self._data.array.copy(deep=True),
1951:                                          dtype=self._data.dtype)
1952:            else:
1953:                data = self._data
1954:        else:
```

**assistant → tool `bash`**

```json
{
  "command": "python -c \"\nimport xarray as xr, copy\nds=xr.Dataset(coords={'x':['foo'],'y':('x',['bar'])},data_vars={'z':('x',['baz'])})\nfor name,obj in [('ds',ds),('da',ds.z)]:\n for d in [False,True]:\n  print(name,d,obj.copy(deep=d).x.variable._data.dtype)\n print('copy',copy.copy(obj).x.variable._data.dtype)\n print('deepcopy',copy.deepcopy(obj).x.variable._data.dtype)\n\""
}
```

**tool result**

```
ds False <U3
ds True <U3
copy <U3
deepcopy <U3
da False <U3
da True <U3
copy <U3
deepcopy <U3
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n 560,590p xarray/tests/test_variable.py; sed -n 2035,2075p xarray/tests/test_dataset.py; sed -n 3460,3515p xarray/tests/test_dataarray.py"
}
```

**tool result**

```
                             periods=10, freq='1h')
        v = self.cls('x', data)
        print(v)  # should not error
        if 'America/New_York' in str(data.dtype):
            # pandas is new enough that it has datetime64 with timezone dtype
            assert v.dtype == 'object'

    def test_multiindex(self):
        idx = pd.MultiIndex.from_product([list('abc'), [0, 1]])
        v = self.cls('x', idx)
        assert_identical(Variable((), ('a', 0)), v[0])
        assert_identical(v, v[:])

    def test_load(self):
        array = self.cls('x', np.arange(5))
        orig_data = array._data
        copied = array.copy(deep=True)
        if array.chunks is None:
            array.load()
            assert type(array._data) is type(orig_data)
            assert type(copied._data) is type(orig_data)
            assert_identical(array, copied)

    def test_getitem_advanced(self):
        v = self.cls(['x', 'y'], [[0, 1, 2], [3, 4, 5]])
        v_data = v.compute().data

        # orthogonal indexing
        v_new = v[([0, 1], [1, 0])]
        assert v_new.dims == ('x', 'y')
        assert_array_equal(v_new, v_data[[0, 1]][:, [1, 0]])

        with pytest.raises(ValueError):
            actual = data.drop_dims('z', errors='wrong_value')

        actual = data.drop_dims(['x', 'y', 'z'], errors='ignore')
        expected = data.drop(['A', 'B', 'x'])
        assert_identical(expected, actual)

    def test_copy(self):
        data = create_test_data()
        data.attrs['Test'] = [1, 2, 3]

        for copied in [data.copy(deep=False), copy(data)]:
            assert_identical(data, copied)
            assert data.encoding == copied.encoding
            # Note: IndexVariable objects with string dtype are always
            # copied because of xarray.core.util.safe_cast_to_index.
            # Limiting the test to data variables.
            for k in data.data_vars:
                v0 = data.variables[k]
                v1 = copied.variables[k]
                assert source_ndarray(v0.data) is source_ndarray(v1.data)
            copied['foo'] = ('z', np.arange(5))
            assert 'foo' not in data

            copied.attrs['foo'] = 'bar'
            assert 'foo' not in data.attrs
            assert data.attrs['Test'] is copied.attrs['Test']

        for copied in [data.copy(deep=True), deepcopy(data)]:
            assert_identical(data, copied)
            for k, v0 in data.variables.items():
                v1 = copied.variables[k]
                assert v0 is not v1

            assert data.attrs['Test'] is not copied.attrs['Test']

    def test_copy_with_data(self):
        orig = create_test_data()
        new_data = {k: np.random.randn(*v.shape)
                    for k, v in orig.data_vars.items()}
         xr.DataArray(xr.IndexVariable('a', np.array([1, 2])),
                      coords={'a': [1, 2]}, dims=['a'])],
        [False,
         xr.DataArray(xr.IndexVariable('a', np.array([999, 2])),
                      coords={'a': [999, 2]}, dims=['a'])]])
    def test_copy_coords(self, deep, expected_orig):
        """The test fails for the shallow copy, and apparently only on Windows
        for some reason. In windows coords seem to be immutable unless it's one
        dataarray deep copied from another."""
        da = xr.DataArray(
            np.ones([2, 2, 2]),
            coords={'a': [1, 2], 'b': ['x', 'y'], 'c': [0, 1]},
            dims=['a', 'b', 'c'])
        da_cp = da.copy(deep)
        da_cp['a'].data[0] = 999

        expected_cp = xr.DataArray(
            xr.IndexVariable('a', np.array([999, 2])),
            coords={'a': [999, 2]}, dims=['a'])
        assert_identical(da_cp['a'], expected_cp)

        assert_identical(da['a'], expected_orig)

    def test_real_and_imag(self):
        array = DataArray(1 + 2j)
        assert_identical(array.real, DataArray(1))
        assert_identical(array.imag, DataArray(2))

    def test_setattr_raises(self):
        array = DataArray(0, coords={'scalar': 1}, attrs={'foo': 'bar'})
        with raises_regex(AttributeError, 'cannot set attr'):
            array.scalar = 2
        with raises_regex(AttributeError, 'cannot set attr'):
            array.foo = 2
        with raises_regex(AttributeError, 'cannot set attr'):
            array.other = 2

    def test_full_like(self):
        # For more thorough tests, see test_variable.py
        da = DataArray(np.random.random(size=(2, 2)),
                       dims=('x', 'y'),
                       attrs={'attr1': 'value1'},
                       coords={'x': [4, 3]},
                       name='helloworld')

        actual = full_like(da, 2)
        expect = da.copy(deep=True)
        expect.values = [[2.0, 2.0], [2.0, 2.0]]
        assert_identical(expect, actual)

        # override dtype
        actual = full_like(da, fill_value=True, dtype=bool)
        expect.values = [[True, True], [True, True]]
        assert expect.dtype == bool
        assert_identical(expect, actual)
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"class .*VariableTest\\|class IndexVariable\" xarray/tests/test_variable.py | head; sed -n 470,510p xarray/tests/test_variable.py"
}
```

**tool result**

```

    def test_concat_mixed_dtypes(self):
        a = self.cls('x', [0, 1])
        b = self.cls('x', ['two'])
        actual = Variable.concat([a, b], dim='x')
        expected = Variable('x', np.array([0, 1, 'two'], dtype=object))
        assert_identical(expected, actual)
        assert actual.dtype == object

    @pytest.mark.parametrize('deep', [True, False])
    def test_copy(self, deep):
        v = self.cls('x', 0.5 * np.arange(10), {'foo': 'bar'})
        w = v.copy(deep=deep)
        assert type(v) is type(w)
        assert_identical(v, w)
        assert v.dtype == w.dtype
        if self.cls is Variable:
            if deep:
                assert (source_ndarray(v.values) is not
                        source_ndarray(w.values))
            else:
                assert (source_ndarray(v.values) is
                        source_ndarray(w.values))
        assert_identical(v, copy(v))

    def test_copy_index(self):
        midx = pd.MultiIndex.from_product([['a', 'b'], [1, 2], [-1, -2]],
                                          names=('one', 'two', 'three'))
        v = self.cls('x', midx)
        for deep in [True, False]:
            w = v.copy(deep=deep)
            assert isinstance(w._data, PandasIndexAdapter)
            assert isinstance(w.to_index(), pd.MultiIndex)
            assert_array_equal(v._data.array, w._data.array)

    def test_copy_with_data(self):
        orig = Variable(('x', 'y'), [[1.5, 2.0], [3.1, 4.3]], {'foo': 'bar'})
        new_data = np.array([[2.5, 5.0], [7.1, 43]])
        actual = orig.copy(data=new_data)
        expected = orig.copy()
        expected.data = new_data
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: xarray/tests/test_variable.py\n@@\n     def test_copy_index(self):\n         midx = pd.MultiIndex.from_product([['a', 'b'], [1, 2], [-1, -2]],\n                                           names=('one', 'two', 'three'))\n         v = self.cls('x', midx)\n         for deep in [True, False]:\n             w = v.copy(deep=deep)\n             assert isinstance(w._data, PandasIndexAdapter)\n             assert isinstance(w.to_index(), pd.MultiIndex)\n             assert_array_equal(v._data.array, w._data.array)\n \n+    def test_copy_index_unicode_dtype(self):\n+        # regression test for GH: unicode indices were cast to object\n+        v = self.cls('x', np.array(['foo', 'bar'], dtype='<U3'))\n+        for deep in [True, False]:\n+            w = v.copy(deep=deep)\n+            assert w.dtype == v.dtype\n+            assert_identical(v, w)\n+\n     def test_copy_with_data(self):\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[xarray/tests/test_variable.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

xarray/tests/test_variable.py now (2152 lines), around the change:
501:            assert isinstance(w._data, PandasIndexAdapter)
502:            assert isinstance(w.to_index(), pd.MultiIndex)
503:            assert_array_equal(v._data.array, w._data.array)
504:
505:    def test_copy_index_unicode_dtype(self):
506:        # regression test for GH: unicode indices were cast to object
507:        v = self.cls('x', np.array(['foo', 'bar'], dtype='<U3'))
508:        for deep in [True, False]:
509:            w = v.copy(deep=deep)
510:            assert w.dtype == v.dtype
511:            assert_identical(v, w)
512:
513:    def test_copy_with_data(self):
514:        orig = Variable(('x', 'y'), [[1.5, 2.0], [3.1, 4.3]], {'foo': 'bar'})
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest xarray/tests/test_variable.py -k \"copy\" -q 2>&1 | tail -20"
}
```

**tool result**

```
xarray/tests/test_variable.py::TestVariableWithDask::test_copy[True]
xarray/tests/test_variable.py::TestVariableWithDask::test_copy[False]
xarray/tests/test_variable.py::TestVariableWithDask::test_copy_index_unicode_dtype
xarray/tests/test_variable.py::TestVariableWithDask::test_copy_index
  /opt/miniconda3/envs/testbed/lib/python3.10/site-packages/setuptools/_distutils/version.py:345: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    other = LooseVersion(other)

xarray/tests/__init__.py:57: 15 warnings
  /testbed/xarray/tests/__init__.py:57: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    return version.LooseVersion(vstring)

xarray/tests/test_variable.py::TestVariableWithDask::test_copy[True]
xarray/tests/test_variable.py::TestVariableWithDask::test_copy[False]
xarray/tests/test_variable.py::TestVariableWithDask::test_copy_index_unicode_dtype
xarray/tests/test_variable.py::TestVariableWithDask::test_copy_index
  /testbed/xarray/core/variable.py:900: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(dask.__version__) > '1.2.2':

-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
24 passed, 231 deselected, 1 xfailed, 34 warnings in 4.40s
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest xarray/tests/test_dataset.py -k \"copy\" xarray/tests/test_dataarray.py -q 2>&1 | tail -5"
}
```

**tool result**

```
  /testbed/xarray/core/alignment.py:138: FutureWarning: Index.__or__ operating as a set operation is deprecated, in the future this will be a logical operation matching Series.__or__.  Use index.union(other) instead.
    index = joiner(matching_indexes)

-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
8 passed, 1500 deselected, 4 xpassed, 32 warnings in 4.40s
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"def test_copy\" xarray/tests/test_dataarray.py xarray/tests/test_dataset.py"
}
```

**tool result**

```
xarray/tests/test_dataarray.py:3445:    def test_copy_with_data(self):
xarray/tests/test_dataarray.py:3465:    def test_copy_coords(self, deep, expected_orig):
xarray/tests/test_dataset.py:2043:    def test_copy(self):
xarray/tests/test_dataset.py:2072:    def test_copy_with_data(self):
xarray/tests/test_dataset.py:2091:    def test_copy_coords(self, deep, expected_orig):
xarray/tests/test_dataset.py:2110:    def test_copy_with_data_errors(self):
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n 2085,2115p xarray/tests/test_dataset.py; sed -n 3440,3468p xarray/tests/test_dataarray.py"
}
```

**tool result**

```
        [True,
         xr.DataArray(xr.IndexVariable('a', np.array([1, 2])),
                      coords={'a': [1, 2]}, dims=['a'])],
        [False,
         xr.DataArray(xr.IndexVariable('a', np.array([999, 2])),
                      coords={'a': [999, 2]}, dims=['a'])]])
    def test_copy_coords(self, deep, expected_orig):
        """The test fails for the shallow copy, and apparently only on Windows
        for some reason. In windows coords seem to be immutable unless it's one
        dataset deep copied from another."""
        ds = xr.DataArray(
            np.ones([2, 2, 2]),
            coords={'a': [1, 2], 'b': ['x', 'y'], 'c': [0, 1]},
            dims=['a', 'b', 'c'],
            name='value').to_dataset()
        ds_cp = ds.copy(deep=deep)
        ds_cp.coords['a'].data[0] = 999

        expected_cp = xr.DataArray(
            xr.IndexVariable('a', np.array([999, 2])),
            coords={'a': [999, 2]}, dims=['a'])
        assert_identical(ds_cp.coords['a'], expected_cp)

        assert_identical(ds.coords['a'], expected_orig)

    def test_copy_with_data_errors(self):
        orig = create_test_data()
        new_var1 = np.arange(orig['var1'].size).reshape(orig['var1'].shape)
        with raises_regex(ValueError, 'Data must be dict-like'):
            orig.copy(data=new_var1)
        with raises_regex(ValueError, 'only contain variables in original'):
            actual = arr.roll(x=1, roll_coords=None)

        expected = DataArray([3, 1, 2], coords=[('x', [2, 0, 1])])
        assert_identical(expected, actual)

    def test_copy_with_data(self):
        orig = DataArray(np.random.random(size=(2, 2)),
                         dims=('x', 'y'),
                         attrs={'attr1': 'value1'},
                         coords={'x': [4, 3]},
                         name='helloworld')
        new_data = np.arange(4).reshape(2, 2)
        actual = orig.copy(data=new_data)
        expected = orig.copy()
        expected.data = new_data
        assert_identical(expected, actual)

    @pytest.mark.xfail(raises=AssertionError)
    @pytest.mark.parametrize('deep, expected_orig', [
        [True,
         xr.DataArray(xr.IndexVariable('a', np.array([1, 2])),
                      coords={'a': [1, 2]}, dims=['a'])],
        [False,
         xr.DataArray(xr.IndexVariable('a', np.array([999, 2])),
                      coords={'a': [999, 2]}, dims=['a'])]])
    def test_copy_coords(self, deep, expected_orig):
        """The test fails for the shallow copy, and apparently only on Windows
        for some reason. In windows coords seem to be immutable unless it's one
        dataarray deep copied from another."""
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: xarray/tests/test_dataset.py\n@@\n     def test_copy_with_data(self):\n         orig = create_test_data()\n         new_data = {k: np.random.randn(*v.shape)\n                     for k, v in orig.data_vars.items()}\n*** End Patch\n"
}
```

**tool result**

```
apply_patch update xarray/tests/test_dataset.py: the patch changed NOTHING — it contains only context lines (no additions or removals), or its changes match the file as-is. Write a hunk with the line to change as "-old line" and its replacement as "+new line". Changing several lines? read_file test_dataset.py and REWRITE it with *** Add File: test_dataset.py using its ACTUAL content plus your change
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: xarray/tests/test_dataset.py\n@@\n     def test_copy_with_data(self):\n         orig = create_test_data()\n         new_data = {k: np.random.randn(*v.shape)\n                     for k, v in orig.data_vars.items()}\n*** End Patch\n"
}
```

**tool result**

```
apply_patch update xarray/tests/test_dataset.py: the patch changed NOTHING — it contains only context lines (no additions or removals), or its changes match the file as-is. Write a hunk with the line to change as "-old line" and its replacement as "+new line". Changing several lines? read_file test_dataset.py and REWRITE it with *** Add File: test_dataset.py using its ACTUAL content plus your change
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: xarray/tests/test_dataset.py\n@@\n             assert data.attrs['Test'] is not copied.attrs['Test']\n \n+    def test_copy_unicode_index_dtype(self):\n+        # regression test: copying should not cast unicode indices to object\n+        ds = Dataset(\n+            coords={'x': ['foo'], 'y': ('x', ['bar'])},\n+            data_vars={'z': ('x', ['baz'])})\n+        for copied in [ds.copy(deep=True), ds.copy(deep=False),\n+                       copy(ds), deepcopy(ds)]:\n+            assert copied['x'].dtype == ds['x'].dtype\n+            assert_identical(ds, copied)\n+\n     def test_copy_with_data(self):\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[xarray/tests/test_dataset.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

xarray/tests/test_dataset.py now (5275 lines), around the change:
2068:                assert v0 is not v1
2069:
2070:            assert data.attrs['Test'] is not copied.attrs['Test']
2071:
2072:    def test_copy_unicode_index_dtype(self):
2073:        # regression test: copying should not cast unicode indices to object
2074:        ds = Dataset(
2075:            coords={'x': ['foo'], 'y': ('x', ['bar'])},
2076:            data_vars={'z': ('x', ['baz'])})
2077:        for copied in [ds.copy(deep=True), ds.copy(deep=False),
2078:                       copy(ds), deepcopy(ds)]:
2079:            assert copied['x'].dtype == ds['x'].dtype
2080:            assert_identical(ds, copied)
2081:
2082:    def test_copy_with_data(self):
2083:        orig = create_test_data()
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: xarray/tests/test_dataarray.py\n@@\n     def test_copy_with_data(self):\n         orig = DataArray(np.random.random(size=(2, 2)),\n                          dims=('x', 'y'),\n                          attrs={'attr1': 'value1'},\n                          coords={'x': [4, 3]},\n                          name='helloworld')\n         new_data = np.arange(4).reshape(2, 2)\n         actual = orig.copy(data=new_data)\n         expected = orig.copy()\n         expected.data = new_data\n         assert_identical(expected, actual)\n \n+    def test_copy_unicode_index_dtype(self):\n+        # regression test: copying should not cast unicode indices to object\n+        da = DataArray(\n+            ['baz'], dims='x',\n+            coords={'x': ['foo'], 'y': ('x', ['bar'])})\n+        for copied in [da.copy(deep=True), da.copy(deep=False),\n+                       copy(da), deepcopy(da)]:\n+            assert copied['x'].dtype == da['x'].dtype\n+            assert_identical(da, copied)\n+\n     @pytest.mark.xfail(raises=AssertionError)\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[xarray/tests/test_dataarray.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

xarray/tests/test_dataarray.py now (4205 lines), around the change:
3454:        expected.data = new_data
3455:        assert_identical(expected, actual)
3456:
3457:    def test_copy_unicode_index_dtype(self):
3458:        # regression test: copying should not cast unicode indices to object
3459:        da = DataArray(
3460:            ['baz'], dims='x',
3461:            coords={'x': ['foo'], 'y': ('x', ['bar'])})
3462:        for copied in [da.copy(deep=True), da.copy(deep=False),
3463:                       copy(da), deepcopy(da)]:
3464:            assert copied['x'].dtype == da['x'].dtype
3465:            assert_identical(da, copied)
3466:
3467:    @pytest.mark.xfail(raises=AssertionError)
3468:    @pytest.mark.parametrize('deep, expected_orig', [
3469:        [True,
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest xarray/tests/test_variable.py xarray/tests/test_dataset.py xarray/tests/test_dataarray.py -k \"copy\" -q 2>&1 | tail -5"
}
```

**tool result**

```

-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
=========================== short test summary info ============================
FAILED xarray/tests/test_dataarray.py::TestDataArray::test_copy_unicode_index_dtype
1 failed, 33 passed, 1731 deselected, 1 xfailed, 4 xpassed, 40 warnings in 6.55s
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest xarray/tests/test_dataarray.py::TestDataArray::test_copy_unicode_index_dtype -q 2>&1 | grep -A 30 \"def test_copy_unicode\""
}
```

**tool result**

```
    def test_copy_unicode_index_dtype(self):
        # regression test: copying should not cast unicode indices to object
        da = DataArray(
            ['baz'], dims='x',
            coords={'x': ['foo'], 'y': ('x', ['bar'])})
        for copied in [da.copy(deep=True), da.copy(deep=False),
>                      copy(da), deepcopy(da)]:
E                      NameError: name 'copy' is not defined

xarray/tests/test_dataarray.py:3463: NameError
=============================== warnings summary ===============================
xarray/core/dask_array_ops.py:11
xarray/core/dask_array_ops.py:11
  /testbed/xarray/core/dask_array_ops.py:11: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(dask.__version__) <= LooseVersion('0.18.2'):

xarray/core/npcompat.py:135
xarray/core/npcompat.py:135
  /testbed/xarray/core/npcompat.py:135: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(np.__version__) >= LooseVersion('1.13'):

xarray/core/dask_array_compat.py:43
xarray/core/dask_array_compat.py:43
  /testbed/xarray/core/dask_array_compat.py:43: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(dask_version) > LooseVersion('0.19.2'):

xarray/plot/utils.py:17
xarray/plot/utils.py:17
  /testbed/xarray/plot/utils.py:17: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(nc_time_axis.__version__) < LooseVersion('1.2.0'):
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"^import copy\\|^from copy\\|import copy\" xarray/tests/test_dataarray.py | head"
}
```

**tool result**

```
5:from copy import deepcopy
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: xarray/tests/test_dataarray.py\n@@\n-from copy import deepcopy\n+from copy import copy, deepcopy\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[xarray/tests/test_dataarray.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

xarray/tests/test_dataarray.py now (4205 lines), around the change:
2:import sys
3:import warnings
4:from collections import OrderedDict
5:from copy import copy, deepcopy
6:from textwrap import dedent
7:
8:import numpy as np
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest xarray/tests/test_variable.py xarray/tests/test_dataset.py xarray/tests/test_dataarray.py -k \"copy\" -q 2>&1 | tail -3"
}
```

**tool result**

```

-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
34 passed, 1731 deselected, 1 xfailed, 4 xpassed, 40 warnings in 5.62s


(this is the fourth time you have made nearly this same bash call this turn — the earlier answers are above. Do not ask it again; do the next real step)
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest xarray/tests/test_variable.py xarray/tests/test_indexing.py -q 2>&1 | tail -3"
}
```

**tool result**

```

-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
366 passed, 11 xfailed, 243 warnings in 9.66s
```

**assistant**

````
Fixed the regression.

**Root cause:** `IndexVariable.copy(deep=True)` in `xarray/core/variable.py` rebuilt the `PandasIndexAdapter` from `self._data.array.copy(deep=True)` without passing the original dtype. `PandasIndexAdapter.__init__` then inferred the dtype from the copied `pandas.Index`, which pandas stores as `object` for string data — so `<U*` indices became `object`. Shallow copies reused the adapter and were unaffected, which matches the reported behavior.

**Fix:** pass `dtype=self._data.dtype` when constructing the new adapter, preserving the original dtype:

```python
data = PandasIndexAdapter(self._data.array.copy(deep=True),
                          dtype=self._data.dtype)
```

This covers `Dataset.copy(deep=True)`, `DataArray.copy(deep=True)`, `copy.copy()` and `copy.deepcopy()`, since they all route through `IndexVariable.copy`.

**Tests added:**
- `test_variable.py::test_copy_index_unicode_dtype` — checks dtype and identity for both deep/shallow copies of an `IndexVariable`.
- `test_dataset.py::test_copy_unicode_index_dtype` — the exact reproducer, across `copy(deep=True/False)`, `copy.copy`, `copy.deepcopy`.
- `test_dataarray.py::test_copy_unicode_index_dtype` — same for `DataArray` (also added the missing `copy` import).

All copy-related tests pass (34 passed), and the full `test_variable.py` + `test_indexing.py` suites pass (366 passed). No commits or tree changes beyond the source/test edits.
````

## Run folder `team-solve-2026-11-06T123029`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `base.txt`

```
779ee6547df2a2a616999a7fb17b39bc4359e267
```

### `baseline-check.log`

```
check: pytest xarray/tests/test_variable.py xarray/tests/test_dataarray.py xarray/tests/test_dataset.py -q
........................................................................ [  4%]
........................................................................ [  8%]
..................xxxx.................................................. [ 12%]
...............xxxxxxx.................................................. [ 16%]
........................................................................ [ 20%]
.............s.s........................................................ [ 24%]
..................XX.................................................... [ 28%]
........................................................................ [ 32%]
........................................................................ [ 36%]
........................................................................ [ 40%]
........................................................................ [ 44%]
........................................................................ [ 48%]
........................................................................ [ 53%]
..........................................................XX........F... [ 57%]
..sF.................................................................... [ 61%]
........................................................................ [ 65%]
.......................F................................................ [ 69%]
........................................................................ [ 73%]
........................................................................ [ 77%]
..............................................................ssssssssss [ 81%]
ssssss.................................................................. [ 85%]
........................................................................ [ 89%]
........................................................................ [ 93%]
........................................................................ [ 97%]
.............................FF....FF                                    [100%]
=================================== FAILURES ===================================
______________________ TestDataset.test_expand_dims_error ______________________

self = <xarray.tests.test_dataset.TestDataset object at 0x7ae972e9fbe0>

    def test_expand_dims_error(self):
        original = Dataset({'x': ('a', np.random.randn(3)),
                            'y': (['b', 'a'], np.random.randn(4, 3)),
                            'z': ('a', np.random.randn(3))},
                           coords={'a': np.linspace(0, 1, 3),
                                   'b': np.linspace(0, 1, 4),
                                   'c': np.linspace(0, 1, 5)},
                           attrs={'key': 'entry'})
    
        with raises_regex(ValueError, 'already exists'):
            original.expand_dims(dim=['x'])
    
        # Make sure it raises true error also for non-dimensional coordinates
        # which has dimension.
        original = original.set_coords('z')
        with raises_regex(ValueError, 'already exists'):
            original.expand_dims(dim=['z'])
    
        original = Dataset({'x': ('a', np.random.randn(3)),
                            'y': (['b', 'a'], np.random.randn(4, 3)),
                            'z': ('a', np.random.randn(3))},
                           coords={'a': np.linspace(0, 1, 3),
                                   'b': np.linspace(0, 1, 4),
                                   'c': np.linspace(0, 1, 5)},
                           attrs={'key': 'entry'})
        with raises_regex(TypeError, 'value of new dimension'):
            original.expand_dims(OrderedDict((("d", 3.2),)))
    
        # TODO: only the code under the if-statement is needed when python 3.5
        #   is no longer supported.
        python36_plus = sys.version_info[0] == 3 and sys.version_info[1] > 5
        if python36_plus:
            with raises_regex(ValueError, 'both keyword and positional'):
>               original.expand_dims(OrderedDict((("d", 4),)), e=4)

xarray/tests/test_dataset.py:2273: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <xarray.Dataset>
Dimensions:  (a: 3, b: 4, c: 5)
Coordinates:
  * a        (a) float64 0.0 0.5 1.0
  * b        (b) fl... -1.113 -0.7831 ... -1.605 0.3476 0.6969
    z        (a) float64 1.002 -0.2431 -0.3726
Attributes:
    key:      entry
dim = OrderedDict([('d', 4)]), axis = None, dim_kwargs = {'e': 4}

    def expand_dims(
        self,
        dim: Union[None, Hashable, Sequence[Hashable],
                   Mapping[Hashable, Any]] = None,
        axis: Union[None, int, Sequence[int]] = None,
        **dim_kwargs: Any
    ) -> 'Dataset':
        """Return a new object with an additional axis (or axes) inserted at
        the corresponding position in the array shape.  The new object is a
        view into the underlying array, not a copy.
    
        If dim is already a scalar coordinate, it will be promoted to a 1D
        coordinate consisting of a single value.
    
        Parameters
        ----------
        dim : hashable, sequence of hashable, mapping, or None
            Dimensions to include on the new variable. If provided as hashable
            or sequence of hashable, then dimensions are inserted with length
            1. If provided as a mapping, then the keys are the new dimensions
            and the values are either integers (giving the length of the new
            dimensions) or array-like (giving the coordinates of the new
            dimensions).
    
            .. note::
    
               For Python 3.5, if ``dim`` is a mapping, then it must be an
               ``OrderedDict``. This is to ensure that the order in which the
               dims are given is maintained.
    
        axis : integer, sequence of integers, or None
            Axis position(s) where new axis is to be inserted (position(s) on
            the result array). If a list (or tuple) of integers is passed,
            multiple axes are inserted. In this case, dim arguments should be
            same length list. If axis=None is passed, all the axes will be
            inserted to the start of the result array.
        **dim_kwargs : int or sequence/ndarray
            The keywords are arbitrary dimensions being inserted and the values
            are either the lengths of the new dims (if int is given), or their
            coordinates. Note, this is an alternative to passing a dict to the
            dim kwarg and will only be used if dim is None.
    
            .. note::
    
               For Python 3.5, ``dim_kwargs`` is not available.
    
        Returns
        -------
        expanded : same type as caller
            This object, but with an additional dimension(s).
        """
        # TODO: get rid of the below code block when python 3.5 is no longer
        #   supported.
        if sys.version < '3.6':
            if isinstance(dim, Mapping) and not isinstance(dim, OrderedDict):
                raise TypeError("dim must be an OrderedDict for python <3.6")
            if dim_kwargs:
>               raise ValueError("dim_kwargs isn't available for python <3.6")
E               ValueError: dim_kwargs isn't available for python <3.6

xarray/core/dataset.py:2659: ValueError

During handling of the above exception, another exception occurred:

self = <xarray.tests.test_dataset.TestDataset object at 0x7ae972e9fbe0>

    def test_expand_dims_error(self):
        original = Dataset({'x': ('a', np.random.randn(3)),
                            'y': (['b', 'a'], np.random.randn(4, 3)),
                            'z': ('a', np.random.randn(3))},
                           coords={'a': np.linspace(0, 1, 3),
                                   'b': np.linspace(0, 1, 4),
                                   'c': np.linspace(0, 1, 5)},
                           attrs={'key': 'entry'})
    
        with raises_regex(ValueError, 'already exists'):
            original.expand_dims(dim=['x'])
    
        # Make sure it raises true error also for non-dimensional coordinates
        # which has dimension.
        original = original.set_coords('z')
        with raises_regex(ValueError, 'already exists'):
            original.expand_dims(dim=['z'])
    
        original = Dataset({'x': ('a', np.random.randn(3)),
                            'y': (['b', 'a'], np.random.randn(4, 3)),
                            'z': ('a', np.random.randn(3))},
                           coords={'a': np.linspace(0, 1, 3),
                                   'b': np.linspace(0, 1, 4),
                                   'c': np.linspace(0, 1, 5)},
                           attrs={'key': 'entry'})
        with raises_regex(TypeError, 'value of new dimension'):
            original.expand_dims(OrderedDict((("d", 3.2),)))
    
        # TODO: only the code under the if-statement is needed when python 3.5
        #   is no longer supported.
        python36_plus = sys.version_info[0] == 3 and sys.version_info[1] > 5
        if python36_plus:
>           with raises_regex(ValueError, 'both keyword and positional'):

xarray/tests/test_dataset.py:2272: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <contextlib._GeneratorContextManager object at 0x7ae96a53e470>
typ = <class 'ValueError'>
value = ValueError("dim_kwargs isn't available for python <3.6")
traceback = <traceback object at 0x7ae96a54bfc0>

    def __exit__(self, typ, value, traceback):
        if typ is None:
            try:
                next(self.gen)
            except StopIteration:
                return False
            else:
                raise RuntimeError("generator didn't stop")
        else:
            if value is None:
                # Need to force instantiation so we can reliably
                # tell if we get the same exception back
                value = typ()
            try:
>               self.gen.throw(typ, value, traceback)
E               AssertionError: exception ValueError("dim_kwargs isn't available for python <3.6") did not match pattern 'both keyword and positional'

/opt/miniconda3/envs/testbed/lib/python3.10/contextlib.py:153: AssertionError
_______________ TestDataset.test_expand_dims_kwargs_python36plus _______________

self = <xarray.tests.test_dataset.TestDataset object at 0x7ae973f2ff40>

    @pytest.mark.skipif(
        sys.version_info[:2] < (3, 6),
        reason='keyword arguments are only ordered on Python 3.6+',
    )
    def test_expand_dims_kwargs_python36plus(self):
        original = Dataset({'x': ('a', np.random.randn(3)),
                            'y': (['b', 'a'], np.random.randn(4, 3))},
                           coords={'a': np.linspace(0, 1, 3),
                                   'b': np.linspace(0, 1, 4),
                                   'c': np.linspace(0, 1, 5)},
                           attrs={'key': 'entry'})
>       other_way = original.expand_dims(e=["l", "m", "n"])

xarray/tests/test_dataset.py:2379: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <xarray.Dataset>
Dimensions:  (a: 3, b: 4, c: 5)
Coordinates:
  * a        (a) float64 0.0 0.5 1.0
  * b        (b) fl...19 1.129 -1.2
    y        (b, a) float64 -1.334 -0.9751 -0.2568 ... 0.124 0.9486 1.009
Attributes:
    key:      entry
dim = None, axis = None, dim_kwargs = {'e': ['l', 'm', 'n']}

    def expand_dims(
        self,
        dim: Union[None, Hashable, Sequence[Hashable],
                   Mapping[Hashable, Any]] = None,
        axis: Union[None, int, Sequence[int]] = None,
        **dim_kwargs: Any
    ) -> 'Dataset':
        """Return a new object with an additional axis (or axes) inserted at
        the corresponding position in the array shape.  The new object is a
        view into the underlying array, not a copy.
    
        If dim is already a scalar coordinate, it will be promoted to a 1D
        coordinate consisting of a single value.
    
        Parameters
        ----------
        dim : hashable, sequence of hashable, mapping, or None
            Dimensions to include on the new variable. If provided as hashable
            or sequence of hashable, then dimensions are inserted with length
            1. If provided as a mapping, then the keys are the new dimensions
            and the values are either integers (giving the length of the new
            dimensions) or array-like (giving the coordinates of the new
            dimensions).
    
            .. note::
    
               For Python 3.5, if ``dim`` is a mapping, then it must be an
               ``OrderedDict``. This is to ensure that the order in which the
               dims are given is maintained.
    
        axis : integer, sequence of integers, or None
            Axis position(s) where new axis is to be inserted (position(s) on
            the result array). If a list (or tuple) of integers is passed,
            multiple axes are inserted. In this case, dim arguments should be
            same length list. If axis=None is passed, all the axes will be
            inserted to the start of the result array.
        **dim_kwargs : int or sequence/ndarray
            The keywords are arbitrary dimensions being inserted and the values
            are either the lengths of the new dims (if int is given), or their
            coordinates. Note, this is an alternative to passing a dict to the
            dim kwarg and will only be used if dim is None.
    
            .. note::
    
               For Python 3.5, ``dim_kwargs`` is not available.
    
        Returns
        -------
        expanded : same type as caller
            This object, but with an additional dimension(s).
        """
        # TODO: get rid of the below code block when python 3.5 is no longer
        #   supported.
        if sys.version < '3.6':
            if isinstance(dim, Mapping) and not isinstance(dim, OrderedDict):
                raise TypeError("dim must be an OrderedDict for python <3.6")
            if dim_kwargs:
>               raise ValueError("dim_kwargs isn't available for python <3.6")
E               ValueError: dim_kwargs isn't available for python <3.6

xarray/core/dataset.py:2659: ValueError
__________________________ test_coarsen_coords_cftime __________________________

    @requires_cftime
    def test_coarsen_coords_cftime():
>       times = xr.cftime_range('2000', periods=6)

xarray/tests/test_dataset.py:4946: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
xarray/coding/cftime_offsets.py:955: in cftime_range
    start = to_cftime_datetime(start, calendar)
xarray/coding/cftime_offsets.py:678: in to_cftime_datetime
    date, _ = _parse_iso8601_with_reso(get_date_type(calendar),
xarray/coding/cftimeindex.py:114: in _parse_iso8601_with_reso
    return default.replace(**replace), resolution
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

>   ???
E   ValueError: Replacing the dayofyr or dayofwk of a datetime is not supported.

src/cftime/_cftime.pyx:1315: ValueError
_______________________ test_differentiate_cftime[True] ________________________

dask = True

    @pytest.mark.skipif(not has_cftime, reason='Test requires cftime.')
    @pytest.mark.parametrize('dask', [True, False])
    def test_differentiate_cftime(dask):
        rs = np.random.RandomState(42)
>       coord = xr.cftime_range('2000', periods=8, freq='2M')

xarray/tests/test_dataset.py:5163: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
xarray/coding/cftime_offsets.py:955: in cftime_range
    start = to_cftime_datetime(start, calendar)
xarray/coding/cftime_offsets.py:678: in to_cftime_datetime
    date, _ = _parse_iso8601_with_reso(get_date_type(calendar),
xarray/coding/cftimeindex.py:114: in _parse_iso8601_with_reso
    return default.replace(**replace), resolution
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

>   ???
E   ValueError: Replacing the dayofyr or dayofwk of a datetime is not supported.

src/cftime/_cftime.pyx:1315: ValueError
_______________________ test_differentiate_cftime[False] _______________________

dask = False

    @pytest.mark.skipif(not has_cftime, reason='Test requires cftime.')
    @pytest.mark.parametrize('dask', [True, False])
    def test_differentiate_cftime(dask):
        rs = np.random.RandomState(42)
>       coord = xr.cftime_range('2000', periods=8, freq='2M')

xarray/tests/test_dataset.py:5163: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
xarray/coding/cftime_offsets.py:955: in cftime_range
    start = to_cftime_datetime(start, calendar)
xarray/coding/cftime_offsets.py:678: in to_cftime_datetime
    date, _ = _parse_iso8601_with_reso(get_date_type(calendar),
xarray/coding/cftimeindex.py:114: in _parse_iso8601_with_reso
    return default.replace(**replace), resolution
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

>   ???
E   ValueError: Replacing the dayofyr or dayofwk of a datetime is not supported.

src/cftime/_cftime.pyx:1315: ValueError
_______________________ test_trapz_datetime[cftime-True] _______________________

dask = True, which_datetime = 'cftime'

    @pytest.mark.parametrize('dask', [True, False])
    @pytest.mark.parametrize('which_datetime', ['np', 'cftime'])
    def test_trapz_datetime(dask, which_datetime):
        rs = np.random.RandomState(42)
        if which_datetime == 'np':
            coord = np.array(
                ['2004-07-13', '2006-01-13', '2010-08-13', '2010-09-13',
                 '2010-10-11', '2010-12-13', '2011-02-13', '2012-08-13'],
                dtype='datetime64')
        else:
            if not has_cftime:
                pytest.skip('Test requires cftime.')
>           coord = xr.cftime_range('2000', periods=8, freq='2D')

xarray/tests/test_dataset.py:5242: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
xarray/coding/cftime_offsets.py:955: in cftime_range
    start = to_cftime_datetime(start, calendar)
xarray/coding/cftime_offsets.py:678: in to_cftime_datetime
    date, _ = _parse_iso8601_with_reso(get_date_type(calendar),
xarray/coding/cftimeindex.py:114: in _parse_iso8601_with_reso
    return default.replace(**replace), resolution
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

>   ???
E   ValueError: Replacing the dayofyr or dayofwk of a datetime is not supported.

src/cftime/_cftime.pyx:1315: ValueError
______________________ test_trapz_datetime[cftime-False] _______________________

dask = False, which_datetime = 'cftime'

    @pytest.mark.parametrize('dask', [True, False])
    @pytest.mark.parametrize('which_datetime', ['np', 'cftime'])
    def test_trapz_datetime(dask, which_datetime):
        rs = np.random.RandomState(42)
        if which_datetime == 'np':
            coord = np.array(
                ['2004-07-13', '2006-01-13', '2010-08-13', '2010-09-13',
                 '2010-10-11', '2010-12-13', '2011-02-13', '2012-08-13'],
                dtype='datetime64')
        else:
            if not has_cftime:
                pytest.skip('Test requires cftime.')
>           coord = xr.cftime_range('2000', periods=8, freq='2D')

xarray/tests/test_dataset.py:5242: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
xarray/coding/cftime_offsets.py:955: in cftime_range
    start = to_cftime_datetime(start, calendar)
xarray/coding/cftime_offsets.py:678: in to_cftime_datetime
    date, _ = _parse_iso8601_with_reso(get_date_type(calendar),
xarray/coding/cftimeindex.py:114: in _parse_iso8601_with_reso
    return default.replace(**replace), resolution
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

>   ???
E   ValueError: Replacing the dayofyr or dayofwk of a datetime is not supported.

src/cftime/_cftime.pyx:1315: ValueError
=============================== warnings summary ===============================
xarray/core/dask_array_ops.py:11
xarray/core/dask_array_ops.py:11
  /testbed/.memdoor/runs/team-solve-2026-11-06T123029/baseline-tree/xarray/core/dask_array_ops.py:11: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(dask.__version__) <= LooseVersion('0.18.2'):

xarray/core/npcompat.py:135
xarray/core/npcompat.py:135
  /testbed/.memdoor/runs/team-solve-2026-11-06T123029/baseline-tree/xarray/core/npcompat.py:135: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(np.__version__) >= LooseVersion('1.13'):

xarray/core/dask_array_compat.py:43
xarray/core/dask_array_compat.py:43
  /testbed/.memdoor/runs/team-solve-2026-11-06T123029/baseline-tree/xarray/core/dask_array_compat.py:43: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(dask_version) > LooseVersion('0.19.2'):

xarray/plot/utils.py:17
xarray/plot/utils.py:17
  /testbed/.memdoor/runs/team-solve-2026-11-06T123029/baseline-tree/xarray/plot/utils.py:17: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(nc_time_axis.__version__) < LooseVersion('1.2.0'):

xarray/plot/plot.py:243
  /testbed/.memdoor/runs/team-solve-2026-11-06T123029/baseline-tree/xarray/plot/plot.py:243: SyntaxWarning: "is" with a literal. Did you mean "=="?
    if args is ():

xarray/core/pdcompat.py:46
  /testbed/.memdoor/runs/team-solve-2026-11-06T123029/baseline-tree/xarray/core/pdcompat.py:46: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(pd.__version__) < '0.25.0':

../../../../../opt/miniconda3/envs/testbed/lib/python3.10/site-packages/setuptools/_distutils/version.py:345: 2 warnings
xarray/tests/test_variable.py: 100 warnings
xarray/tests/test_dataarray.py: 78 warnings
xarray/tests/test_dataset.py: 53 warnings
  /opt/miniconda3/envs/testbed/lib/python3.10/site-packages/setuptools/_distutils/version.py:345: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    other = LooseVersion(other)

xarray/tests/__init__.py:57: 17 warnings
xarray/tests/test_dataarray.py: 2 warnings
xarray/tests/test_dataset.py: 1 warning
  /testbed/.memdoor/runs/team-solve-2026-11-06T123029/baseline-tree/xarray/tests/__init__.py:57: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    return version.LooseVersion(vstring)

xarray/tests/test_variable.py: 12 warnings
xarray/tests/test_dataarray.py: 12 warnings
xarray/tests/test_dataset.py: 63 warnings
  /testbed/.memdoor/runs/team-solve-2026-11-06T123029/baseline-tree/xarray/core/variable.py:1596: DeprecationWarning: the `interpolation=` argument to nanpercentile was renamed to `method=`, which has additional options.
  Users of the modes 'nearest', 'lower', 'higher', or 'midpoint' are encouraged to review the method they used. (Deprecated NumPy 1.22)
    qs = np.nanpercentile(self.data, q * 100., axis=axis,

xarray/tests/test_variable.py: 98 warnings
xarray/tests/test_dataarray.py: 61 warnings
xarray/tests/test_dataset.py: 45 warnings
  /testbed/.memdoor/runs/team-solve-2026-11-06T123029/baseline-tree/xarray/core/variable.py:900: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(dask.__version__) > '1.2.2':

xarray/tests/test_variable.py::TestVariableWithDask::test_eq_all_dtypes
  /opt/miniconda3/envs/testbed/lib/python3.10/site-packages/dask/core.py:119: FutureWarning: elementwise comparison failed; returning scalar instead, but in the future will perform elementwise comparison
    return func(*(_execute_task(a, cache) for a in args))

xarray/tests/test_variable.py::TestVariableWithDask::test_equals_all_dtypes
  /testbed/.memdoor/runs/team-solve-2026-11-06T123029/baseline-tree/xarray/tests/test_variable.py:1802: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if '0.18.2' <= LooseVersion(dask.__version__) < '0.19.1':

xarray/tests/test_variable.py::test_raise_no_warning_for_nan_in_binary_ops
xarray/tests/test_dataarray.py::test_raise_no_warning_for_nan_in_binary_ops
xarray/tests/test_dataset.py::TestDataset::test_reindex_warning
xarray/tests/test_dataset.py::test_raise_no_warning_for_nan_in_binary_ops
  /opt/miniconda3/envs/testbed/lib/python3.10/site-packages/_pytest/python.py:194: PytestRemovedIn8Warning: Passing None has been deprecated.
  See https://docs.pytest.org/en/latest/how-to/capture-warnings.html#additional-use-cases-of-warnings-in-tests for alternatives in common use cases.
    result = testfunction(**testargs)

xarray/tests/test_dataarray.py: 77 warnings
xarray/tests/test_dataset.py: 404 warnings
  /testbed/.memdoor/runs/team-solve-2026-11-06T123029/baseline-tree/xarray/core/formatting.py:147: DeprecationWarning: `np.float` is a deprecated alias for the builtin `float`. To silence this warning, use `float` by itself. Doing this will not modify any behavior and is safe. If you specifically wanted the numpy scalar type, use `np.float64` here.
  Deprecated in NumPy 1.20; for more details and guidance: https://numpy.org/devdocs/release/1.20.0-notes.html#deprecations
    elif isinstance(x, (float, np.float)):

xarray/tests/test_dataarray.py: 5 warnings
xarray/tests/test_dataset.py: 6 warnings
  /testbed/.memdoor/runs/team-solve-2026-11-06T123029/baseline-tree/xarray/core/alignment.py:138: FutureWarning: Index.__and__ operating as a set operation is deprecated, in the future this will be a logical operation matching Series.__and__.  Use index.intersection(other) instead.
    index = joiner(matching_indexes)

xarray/tests/test_dataarray.py: 34 warnings
xarray/tests/test_dataset.py: 30 warnings
  /testbed/.memdoor/runs/team-solve-2026-11-06T123029/baseline-tree/xarray/core/dataset.py:2897: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(pd.__version__) < LooseVersion('0.19.0'):

xarray/tests/test_dataarray.py: 10 warnings
xarray/tests/test_dataset.py: 7 warnings
  /testbed/.memdoor/runs/team-solve-2026-11-06T123029/baseline-tree/xarray/core/dataset.py:3073: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(pd.__version__) >= "0.20":

xarray/tests/test_dataarray.py: 14 warnings
xarray/tests/test_dataset.py: 19 warnings
  /testbed/.memdoor/runs/team-solve-2026-11-06T123029/baseline-tree/xarray/core/alignment.py:138: FutureWarning: Index.__or__ operating as a set operation is deprecated, in the future this will be a logical operation matching Series.__or__.  Use index.union(other) instead.
    index = joiner(matching_indexes)

xarray/tests/test_dataarray.py::TestDataArray::test_reindex_regressions
  /testbed/.memdoor/runs/team-solve-2026-11-06T123029/baseline-tree/xarray/tests/test_dataarray.py:1306: DeprecationWarning: `np.complex` is a deprecated alias for the builtin `complex`. To silence this warning, use `complex` by itself. Doing this will not modify any behavior and is safe. If you specifically wanted the numpy scalar type, use `np.complex128` here.
  Deprecated in NumPy 1.20; for more details and guidance: https://numpy.org/devdocs/release/1.20.0-notes.html#deprecations
    x = np.array([1, 2, 3], dtype=np.complex)

xarray/tests/test_dataarray.py::TestDataArray::test_stack_unstack
  /testbed/.memdoor/runs/team-solve-2026-11-06T123029/baseline-tree/xarray/tests/test_dataarray.py:1792: FutureWarning: pandas.Int64Index is deprecated and will be removed from pandas in a future version. Use pandas.Index with the appropriate dtype instead.
    b = pd.MultiIndex(levels=[pd.Int64Index([]), pd.Int64Index([0])],

xarray/tests/test_dataarray.py::TestDataArray::test_stack_unstack
  /opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/util/__init__.py:16: FutureWarning: pandas.util.testing is deprecated. Use the functions in the public API at pandas.testing instead.
    import pandas.util.testing

xarray/tests/test_dataarray.py: 9 warnings
xarray/tests/test_dataset.py: 5 warnings
  /testbed/.memdoor/runs/team-solve-2026-11-06T123029/baseline-tree/xarray/core/groupby.py:153: FutureWarning: is_monotonic is deprecated and will be removed in a future version. Use is_monotonic_increasing instead.
    return index.is_unique and index.is_monotonic

xarray/tests/test_dataarray.py::TestDataArray::test_groupby_bins_sort
  /testbed/.memdoor/runs/team-solve-2026-11-06T123029/baseline-tree/xarray/tests/test_dataarray.py:2483: FutureWarning: is_monotonic is deprecated and will be removed in a future version. Use is_monotonic_increasing instead.
    assert binned_mean.to_index().is_monotonic

xarray/tests/test_dataarray.py: 41 warnings
xarray/tests/test_dataset.py: 10 warnings
  /testbed/.memdoor/runs/team-solve-2026-11-06T123029/baseline-tree/xarray/core/common.py:840: FutureWarning: 'base' in .resample() and in Grouper() is deprecated.
  The new arguments that you should use are 'offset' or 'origin'.
  
  >>> df.resample(freq="3s", base=2)
  
  becomes:
  
  >>> df.resample(freq="3s", offset="2s")
  
    grouper = pd.Grouper(freq=freq, closed=closed, label=label,

xarray/tests/test_dataarray.py: 40 warnings
xarray/tests/test_dataset.py: 10 warnings
  /testbed/.memdoor/runs/team-solve-2026-11-06T123029/baseline-tree/xarray/core/groupby.py:264: FutureWarning: is_monotonic is deprecated and will be removed in a future version. Use is_monotonic_increasing instead.
    if not index.is_monotonic:

xarray/tests/test_dataarray.py::TestDataArray::test_resample
xarray/tests/test_dataset.py::TestDataset::test_resample_loffset
  /testbed/.memdoor/runs/team-solve-2026-11-06T123029/baseline-tree/xarray/core/common.py:840: FutureWarning: 'loffset' in .resample() and in Grouper() is deprecated.
  
  >>> df.resample(freq="3s", loffset="8H")
  
  becomes:
  
  >>> from pandas.tseries.frequencies import to_offset
  >>> df = df.resample(freq="3s").mean()
  >>> df.index = df.index.to_timestamp() + to_offset("8H")
  
    grouper = pd.Grouper(freq=freq, closed=closed, label=label,

xarray/tests/test_dataarray.py::TestDataArray::test_resample
  /testbed/.memdoor/runs/team-solve-2026-11-06T123029/baseline-tree/xarray/tests/test_dataarray.py:2497: FutureWarning: 'loffset' in .resample() and in Grouper() is deprecated.
  
  >>> df.resample(freq="3s", loffset="8H")
  
  becomes:
  
  >>> from pandas.tseries.frequencies import to_offset
  >>> df = df.resample(freq="3s").mean()
  >>> df.index = df.index.to_timestamp() + to_offset("8H")
  
    expected = DataArray(array.to_series().resample('24H', loffset='-12H')

xarray/tests/test_dataarray.py::TestDataArray::test_resample_drop_nondim_coords
xarray/tests/test_dataarray.py::TestDataArray::test_upsample_interpolate
xarray/tests/test_dataarray.py::TestDataArray::test_upsample_interpolate
xarray/tests/test_dataarray.py::TestDataArray::test_upsample_interpolate_bug_2197
xarray/tests/test_dataarray.py::TestDataArray::test_upsample_interpolate_regression_1605
xarray/tests/test_dataarray.py::TestDataArray::test_upsample_interpolate_dask
xarray/tests/test_dataarray.py::TestDataArray::test_upsample_interpolate_dask
xarray/tests/test_dataarray.py::TestDataArray::test_upsample_interpolate_dask
xarray/tests/test_dataset.py::TestDataset::test_resample_drop_nondim_coords
  /testbed/.memdoor/runs/team-solve-2026-11-06T123029/baseline-tree/xarray/core/missing.py:380: FutureWarning: Passing method to DatetimeIndex.get_loc is deprecated and will raise in a future version. Use index.get_indexer([item], method=...) instead.
    imin = index.get_loc(np.min(new_x.values), method='nearest')

xarray/tests/test_dataarray.py::TestDataArray::test_resample_drop_nondim_coords
xarray/tests/test_dataarray.py::TestDataArray::test_upsample_interpolate
xarray/tests/test_dataarray.py::TestDataArray::test_upsample_interpolate
xarray/tests/test_dataarray.py::TestDataArray::test_upsample_interpolate_bug_2197
xarray/tests/test_dataarray.py::TestDataArray::test_upsample_interpolate_regression_1605
xarray/tests/test_dataarray.py::TestDataArray::test_upsample_interpolate_dask
xarray/tests/test_dataarray.py::TestDataArray::test_upsample_interpolate_dask
xarray/tests/test_dataarray.py::TestDataArray::test_upsample_interpolate_dask
xarray/tests/test_dataset.py::TestDataset::test_resample_drop_nondim_coords
  /testbed/.memdoor/runs/team-solve-2026-11-06T123029/baseline-tree/xarray/core/missing.py:381: FutureWarning: Passing method to DatetimeIndex.get_loc is deprecated and will raise in a future version. Use index.get_indexer([item], method=...) instead.
    imax = index.get_loc(np.max(new_x.values), method='nearest')

xarray/tests/test_dataarray.py::TestDataArray::test_upsample
  /testbed/.memdoor/runs/team-solve-2026-11-06T123029/baseline-tree/xarray/tests/test_dataarray.py:2630: FutureWarning: pad is deprecated and will be removed in a future version. Use ffill instead.
    expected = DataArray(array.to_series().resample('3H').pad())

xarray/tests/test_dataarray.py::TestDataArray::test_to_and_from_empty_series
  /testbed/.memdoor/runs/team-solve-2026-11-06T123029/baseline-tree/xarray/tests/test_dataarray.py:3083: FutureWarning: The default dtype for empty Series will be 'object' instead of 'float64' in a future version. Specify a dtype explicitly to silence this warning.
    expected = pd.Series([])

xarray/tests/test_dataarray.py::TestDataArray::test_to_and_from_cdms2_classic
xarray/tests/test_dataarray.py::TestIrisConversion::test_to_and_from_iris
xarray/tests/test_dataarray.py::TestIrisConversion::test_to_and_from_iris
xarray/tests/test_dataarray.py::TestIrisConversion::test_to_and_from_iris_dask
xarray/tests/test_dataarray.py::TestIrisConversion::test_to_and_from_iris_dask
  /testbed/.memdoor/runs/team-solve-2026-11-06T123029/baseline-tree/xarray/coding/times.py:212: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(pd.__version__) < '0.25.0':

xarray/tests/test_dataarray.py::TestDataArray::test_to_and_from_cdms2_sgrid
xarray/tests/test_dataarray.py::TestDataArray::test_to_and_from_cdms2_sgrid
xarray/tests/test_dataarray.py::TestDataArray::test_to_and_from_cdms2_sgrid
xarray/tests/test_dataarray.py::TestDataArray::test_to_and_from_cdms2_sgrid
  /opt/miniconda3/envs/testbed/lib/python3.10/site-packages/numpy/ma/core.py:7939: DeprecationWarning: elementwise comparison failed; this will raise an error in the future.
    if not np.all(xinf == filled(np.isinf(y), False)):

xarray/tests/test_dataarray.py: 4 warnings
xarray/tests/test_dataset.py: 8 warnings
  /testbed/.memdoor/runs/team-solve-2026-11-06T123029/baseline-tree/xarray/core/dataset.py:4390: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    and LooseVersion(np.__version__) < LooseVersion('1.11.0')):

xarray/tests/test_dataarray.py: 1952 warnings
xarray/tests/test_dataset.py: 5320 warnings
  /testbed/.memdoor/runs/team-solve-2026-11-06T123029/baseline-tree/xarray/core/rolling.py:75: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    (LooseVersion(bottleneck.__version__) < LooseVersion('1.0'))):

xarray/tests/test_dataarray.py: 386 warnings
xarray/tests/test_dataset.py: 1016 warnings
  /testbed/.memdoor/runs/team-solve-2026-11-06T123029/baseline-tree/xarray/core/rolling.py:322: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if (LooseVersion(np.__version__) < LooseVersion('1.13') and

xarray/tests/test_dataset.py::TestDataset::test_constructor_pandas_single
  /testbed/.memdoor/runs/team-solve-2026-11-06T123029/baseline-tree/xarray/core/merge.py:321: FutureWarning: iteritems is deprecated and will be removed in a future version. Use .items instead.
    obj = OrderedDict(obj.iteritems())

xarray/tests/test_dataset.py::TestDataset::test_sel_method
xarray/tests/test_dataset.py::TestDataset::test_sel_method
xarray/tests/test_dataset.py::TestDataset::test_sel_method
  /testbed/.memdoor/runs/team-solve-2026-11-06T123029/baseline-tree/xarray/core/indexing.py:108: FutureWarning: Passing method to Float64Index.get_loc is deprecated and will raise in a future version. Use index.get_indexer([item], method=...) instead.
    return index.get_loc(label, **kwargs)

xarray/tests/test_dataset.py::TestDataset::test_resample_loffset
  /testbed/.memdoor/runs/team-solve-2026-11-06T123029/baseline-tree/xarray/tests/test_dataset.py:3216: FutureWarning: 'loffset' in .resample() and in Grouper() is deprecated.
  
  >>> df.resample(freq="3s", loffset="8H")
  
  becomes:
  
  >>> from pandas.tseries.frequencies import to_offset
  >>> df = df.resample(freq="3s").mean()
  >>> df.index = df.index.to_timestamp() + to_offset("8H")
  
    expected = xr.DataArray(ds.bar.to_series()

xarray/tests/test_dataset.py::test_coarsen_coords[1-True]
xarray/tests/test_dataset.py::test_coarsen_coords[1-False]
  /testbed/.memdoor/runs/team-solve-2026-11-06T123029/baseline-tree/xarray/tests/test_dataset.py:4940: UserWarning: Parsing dates in DD/MM/YYYY format when dayfirst=False (the default) was specified. This may lead to inconsistently parsed dates! Specify a format to ensure consistent parsing.
    coords={'time': pd.date_range('15/12/1999', periods=364)})

-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
=========================== short test summary info ============================
FAILED xarray/tests/test_dataset.py::TestDataset::test_expand_dims_error - As...
FAILED xarray/tests/test_dataset.py::TestDataset::test_expand_dims_kwargs_python36plus
FAILED xarray/tests/test_dataset.py::test_coarsen_coords_cftime - ValueError:...
FAILED xarray/tests/test_dataset.py::test_differentiate_cftime[True] - ValueE...
FAILED xarray/tests/test_dataset.py::test_differentiate_cftime[False] - Value...
FAILED xarray/tests/test_dataset.py::test_trapz_datetime[cftime-True] - Value...
FAILED xarray/tests/test_dataset.py::test_trapz_datetime[cftime-False] - Valu...
7 failed, 1724 passed, 19 skipped, 11 xfailed, 4 xpassed, 10010 warnings in 39.10s
```

### `baseline-status.txt`

```
1
```

### `changes.diff`

```diff
diff --git a/xarray/core/variable.py b/xarray/core/variable.py
index 379be8f5..4dc056af 100644
--- a/xarray/core/variable.py
+++ b/xarray/core/variable.py
@@ -1947,7 +1947,8 @@ class IndexVariable(Variable):
                 # point, which doesn't have a copy method, so make a deep copy
                 # of the underlying `pandas.MultiIndex` and create a new
                 # `PandasIndexAdapter` instance with it.
-                data = PandasIndexAdapter(self._data.array.copy(deep=True))
+                data = PandasIndexAdapter(self._data.array.copy(deep=True),
+                                          dtype=self._data.dtype)
             else:
                 data = self._data
         else:
diff --git a/xarray/tests/test_dataarray.py b/xarray/tests/test_dataarray.py
index 5697704b..989ba556 100644
--- a/xarray/tests/test_dataarray.py
+++ b/xarray/tests/test_dataarray.py
@@ -2,7 +2,7 @@ import pickle
 import sys
 import warnings
 from collections import OrderedDict
-from copy import deepcopy
+from copy import copy, deepcopy
 from textwrap import dedent
 
 import numpy as np
@@ -3454,6 +3454,16 @@ class TestDataArray:
         expected.data = new_data
         assert_identical(expected, actual)
 
+    def test_copy_unicode_index_dtype(self):
+        # regression test: copying should not cast unicode indices to object
+        da = DataArray(
+            ['baz'], dims='x',
+            coords={'x': ['foo'], 'y': ('x', ['bar'])})
+        for copied in [da.copy(deep=True), da.copy(deep=False),
+                       copy(da), deepcopy(da)]:
+            assert copied['x'].dtype == da['x'].dtype
+            assert_identical(da, copied)
+
     @pytest.mark.xfail(raises=AssertionError)
     @pytest.mark.parametrize('deep, expected_orig', [
         [True,
diff --git a/xarray/tests/test_dataset.py b/xarray/tests/test_dataset.py
index fc6f7f36..31ac6568 100644
--- a/xarray/tests/test_dataset.py
+++ b/xarray/tests/test_dataset.py
@@ -2069,6 +2069,16 @@ class TestDataset:
 
             assert data.attrs['Test'] is not copied.attrs['Test']
 
+    def test_copy_unicode_index_dtype(self):
+        # regression test: copying should not cast unicode indices to object
+        ds = Dataset(
+            coords={'x': ['foo'], 'y': ('x', ['bar'])},
+            data_vars={'z': ('x', ['baz'])})
+        for copied in [ds.copy(deep=True), ds.copy(deep=False),
+                       copy(ds), deepcopy(ds)]:
+            assert copied['x'].dtype == ds['x'].dtype
+            assert_identical(ds, copied)
+
     def test_copy_with_data(self):
         orig = create_test_data()
         new_data = {k: np.random.randn(*v.shape)
diff --git a/xarray/tests/test_variable.py b/xarray/tests/test_variable.py
index 73d2a40b..ae2bfa0a 100644
--- a/xarray/tests/test_variable.py
+++ b/xarray/tests/test_variable.py
@@ -502,6 +502,14 @@ class VariableSubclassobjects:
             assert isinstance(w.to_index(), pd.MultiIndex)
             assert_array_equal(v._data.array, w._data.array)
 
+    def test_copy_index_unicode_dtype(self):
+        # regression test for GH: unicode indices were cast to object
+        v = self.cls('x', np.array(['foo', 'bar'], dtype='<U3'))
+        for deep in [True, False]:
+            w = v.copy(deep=deep)
+            assert w.dtype == v.dtype
+            assert_identical(v, w)
+
     def test_copy_with_data(self):
         orig = Variable(('x', 'y'), [[1.5, 2.0], [3.1, 4.3]], {'foo': 'bar'})
         new_data = np.array([[2.5, 5.0], [7.1, 43]])
```

### `check-kind.txt`

```
command
```

### `context.md`

````
# task.md

# Task

## Prompt

REGRESSION: copy(deep=True) casts unicode indices to object
Dataset.copy(deep=True) and DataArray.copy (deep=True/False) accidentally cast IndexVariable's with dtype='<U*' to object. Same applies to copy.copy() and copy.deepcopy().

This is a regression in xarray >= 0.12.2. xarray 0.12.1 and earlier are unaffected.

```

In [1]: ds = xarray.Dataset(
   ...:     coords={'x': ['foo'], 'y': ('x', ['bar'])},
   ...:     data_vars={'z': ('x', ['baz'])})                                                              

In [2]: ds                                                                                                                                                                                                                     
Out[2]: 
<xarray.Dataset>
Dimensions:  (x: 1)
Coordinates:
  * x        (x) <U3 'foo'
    y        (x) <U3 'bar'
Data variables:
    z        (x) <U3 'baz'

In [3]: ds.copy()                                                                                                                                                                                                              
Out[3]: 
<xarray.Dataset>
Dimensions:  (x: 1)
Coordinates:
  * x        (x) <U3 'foo'
    y        (x) <U3 'bar'
Data variables:
    z        (x) <U3 'baz'

In [4]: ds.copy(deep=True)                                                                                                                                                                                                     
Out[4]: 
<xarray.Dataset>
Dimensions:  (x: 1)
Coordinates:
  * x        (x) object 'foo'
    y        (x) <U3 'bar'
Data variables:
    z        (x) <U3 'baz'

In [5]: ds.z                                                                                                                                                                                                                   
Out[5]: 
<xarray.DataArray 'z' (x: 1)>
array(['baz'], dtype='<U3')
Coordinates:
  * x        (x) <U3 'foo'
    y        (x) <U3 'bar'

In [6]: ds.z.copy()                                                                                                                                                                                                            
Out[6]: 
<xarray.DataArray 'z' (x: 1)>
array(['baz'], dtype='<U3')
Coordinates:
  * x        (x) object 'foo'
    y        (x) <U3 'bar'

In [7]: ds.z.copy(deep=True)                                                                                                                                                                                                   
Out[7]: 
<xarray.DataArray 'z' (x: 1)>
array(['baz'], dtype='<U3')
Coordinates:
  * x        (x) object 'foo'
    y        (x) <U3 'bar'
```

## Deliverable

changes to this tree

## Check

`pytest xarray/tests/test_variable.py xarray/tests/test_dataarray.py xarray/tests/test_dataset.py -q`

## Scope

`xarray/core/indexing.py`
`xarray/core/variable.py`
`xarray/tests/test_variable.py`
`xarray/tests/test_dataarray.py`
`xarray/tests/test_dataset.py`

## Done when

- `Dataset.copy(deep=True)` preserves a unicode index coordinate’s dtype as `<U*`, not `object`.
- `DataArray.copy(deep=True)` and `DataArray.copy(deep=False)` preserve a unicode index coordinate’s dtype as `<U*`.
- `copy.copy()` and `copy.deepcopy()` on `Dataset`, `DataArray`, and `IndexVariable` preserve unicode index dtype.
- The copied index still contains the same values and remains usable as an index.



# plan.md

## Deliverable
changes to this tree

## Check
`pytest xarray/tests/test_variable.py xarray/tests/test_dataarray.py xarray/tests/test_dataset.py -q`

## Scope
`xarray/core/indexing.py`
`xarray/core/variable.py`
`xarray/tests/test_variable.py`
`xarray/tests/test_dataarray.py`
`xarray/tests/test_dataset.py`

## Done when
- `Dataset.copy(deep=True)` preserves a unicode index coordinate’s dtype as `<U*`, not `object`.
- `DataArray.copy(deep=True)` and `DataArray.copy(deep=False)` preserve a unicode index coordinate’s dtype as `<U*`.
- `copy.copy()` and `copy.deepcopy()` on `Dataset`, `DataArray`, and `IndexVariable` preserve unicode index dtype.
- The copied index still contains the same values and remains usable as an index.

## Approach
The regression is in the index adapter’s copy path: deep-copying an `IndexVariable` rebuilds the adapter from a copied `pandas.Index`, whose dtype is `object`, and drops the original numpy dtype (`<U*`). Preserve the adapter’s stored dtype when copying.

Candidate approaches:
1. Minimal fix in `PandasIndexAdapter.copy`: pass `dtype=self._dtype` in both deep and shallow branches. This covers `Variable.copy`, `Dataset.copy`, `DataArray.copy`, and the `copy` module paths if they route through the adapter.
2. Override `IndexVariable.copy` / `__copy__` / `__deepcopy__` to preserve dtype explicitly. More code and more places to keep consistent; risks missing adapter-level copies.
3. Change `PandasIndexAdapter.__init__` to infer dtype from the original array before converting to `pandas.Index`. Broader behavior change and more likely to affect unrelated construction paths.

Add focused regression tests for unicode index coordinates under `Dataset.copy(deep=True)`, `DataArray.copy(deep=True/False)`, and `copy.copy` / `copy.deepcopy`.


# xarray/core/indexing.py

```
import functools
import operator
from collections import defaultdict
from contextlib import suppress
from datetime import timedelta
from typing import Sequence

import numpy as np
import pandas as pd

from . import duck_array_ops, nputils, utils
from .pycompat import dask_array_type, integer_types
from .utils import is_dict_like


def expanded_indexer(key, ndim):
    """Given a key for indexing an ndarray, return an equivalent key which is a
    tuple with length equal to the number of dimensions.

    The expansion is done by replacing all `Ellipsis` items with the right
    number of full slices and then padding the key with full slices so that it
    reaches the appropriate dimensionality.
    """
    if not isinstance(key, tuple):
        # numpy treats non-tuple keys equivalent to tuples of length 1
        key = (key,)
    new_key = []
    # handling Ellipsis right is a little tricky, see:
    # http://docs.scipy.org/doc/numpy/reference/arrays.indexing.html#advanced-indexing
    found_ellipsis = False
    for k in key:
        if k is Ellipsis:
            if not found_ellipsis:
                new_key.extend((ndim + 1 - len(key)) * [slice(None)])
                found_ellipsis = True
            else:
                new_key.append(slice(None))
        else:
            new_key.append(k)
    if len(new_key) > ndim:
        raise IndexError('too many indices')
    new_key.extend((ndim - len(new_key)) * [slice(None)])
    return tuple(new_key)


def _expand_slice(slice_, size):
    return np.arange(*slice_.indices(size))


def _sanitize_slice_element(x):
    from .variable import Variable
    from .dataarray import DataArray

    if isinstance(x, (Variable, DataArray)):
        x = x.values

    if isinstance(x, np.ndarray):
        if x.ndim != 0:
            raise ValueError('cannot use non-scalar arrays in a slice for '
                             'xarray indexing: {}'.format(x))
        x = x[()]

    if isinstance(x, np.timedelta64):
        # pandas does not support indexing with np.timedelta64 yet:
        # https://github.com/pandas-dev/pandas/issues/20393
        x = pd.Timedelta(x)

    return x


def _asarray_tuplesafe(values):
    """
    Convert values into a numpy array of at most 1-dimension, while preserving
    tuples.

    Adapted from pandas.core.common._asarray_tuplesafe
    """
    if isinstance(values, tuple):
        result = utils.to_0d_object_array(values)
    else:
        result = np.asarray(values)
        if result.ndim == 2:
            result = np.empty(len(values), dtype=object)
            result[:] = values

    return result


def _is_nested_tuple(possible_tuple):
    return (isinstance(possible_tuple, tuple) and
            any(isinstance(value, (tuple, list, slice))
                for value in possible_tuple))


def _index_method_kwargs(method, tolerance):
    # backwards compatibility for pandas<0.16 (method) or pandas<0.17
    # (tolerance)
    kwargs = {}
    if method is not None:
        kwargs['method'] = method
    if tolerance is not None:
        kwargs['tolerance'] = tolerance
    return kwargs


def get_loc(index, label, method=None, tolerance=None):
    kwargs = _index_method_kwargs(method, tolerance)
    return index.get_loc(label, **kwargs)


def get_indexer_nd(index, labels, method=None, tolerance=None):
    """ Call pd.Index.get_indexer(labels). """
    kwargs = _index_method_kwargs(method, tolerance)

    flat_labels = np.ravel(labels)
    flat_indexer = index.get_indexer(flat_labels, **kwargs)
    indexer = flat_indexer.reshape(labels.shape)
    return indexer


def convert_label_indexer(index, label, index_name='', method=None,
                          tolerance=None):
    """Given a pandas.Index and labels (e.g., from __getitem__) for one
    dimension, return an indexer suitable for indexing an ndarray along that
    dimension. If `index` is a pandas.MultiIndex and depending on `label`,
    return a new pandas.Index or pandas.MultiIndex (otherwise return None).
    """
    new_index = None

    if isinstance(label, slice):
        if method is not None or tolerance is not None:
            raise NotImplementedError(
                'cannot use ``method`` argument if any indexers are '
                'slice objects')
        indexer = index.slice_indexer(_sanitize_slice_element(label.start),
                                      _sanitize_slice_element(label.stop),
                                      _sanitize_slice_element(label.step))
        if not isinstance(indexer, slice):
            # unlike pandas, in xarray we never want to silently convert a
            # slice indexer into an array indexer
            raise KeyError('cannot represent labeled-based slice indexer for '
                           'dimension %r with a slice over integer positions; '
                           'the index is unsorted or non-unique' % index_name)

    elif is_dict_like(label):
        is_nested_vals = _is_nested_tuple(tuple(label.values()))
        if not isinstance(index, pd.MultiIndex):
            raise ValueError('cannot use a dict-like object for selection on '
                             'a dimension that does not have a MultiIndex')
        elif len(label) == index.nlevels and not is_nested_vals:
            indexer = index.get_loc(tuple((label[k] for k in index.names)))
        else:
            for k, v in label.items():
                # index should be an item (i.e. Hashable) not an array-like
                if isinstance(v, Sequence) and not isinstance(v, str):
                    raise ValueError('Vectorized selection is not '
                                     'available along level variable: ' + k)
            indexer, new_index = index.get_loc_level(
                tuple(label.values()), level=tuple(label.keys()))

            # GH2619. Raise a KeyError if nothing is chosen
            if indexer.dtype.kind == 'b' and indexer.sum() == 0:
                raise KeyError('{} not found'.format(label))

    elif isinstance(label, tuple) and isinstance(index, pd.MultiIndex):
        if _is_nested_tuple(label):
            indexer = index.get_locs(label)
        elif len(label) == index.nlevels:
            indexer = index.get_loc(label)
        else:
            indexer, new_index = index.get_loc_level(
                label, level=list(range(len(label)))
            )
    else:
        label = (label if getattr(label, 'ndim', 1) > 1  # vectorized-indexing
                 else _asarray_tuplesafe(label))
        if label.ndim == 0:
            if isinstance(index, pd.MultiIndex):
                indexer, new_index = index.get_loc_level(label.item(), level=0)
            else:
                indexer = get_loc(index, label.item(), method, tolerance)
        elif label.dtype.kind == 'b':
            indexer = label
        else:
            if isinstance(index, pd.MultiIndex) and label.ndim > 1:
                raise ValueError('Vectorized selection is not available along '
                                 'MultiIndex variable: ' + index_name)
            indexer = get_indexer_nd(index, label, method, tolerance)
            if np.any(indexer < 0):
                raise KeyError('not all values found in index %r'
                               % index_name)
    return indexer, new_index


def get_dim_indexers(data_obj, indexers):
    """Given a xarray data object and label based indexers, return a mapping
    of label indexers with only dimension names as keys.

    It groups multiple level indexers given on a multi-index dimension
    into a single, dictionary indexer for that dimension (Raise a ValueError
    if it is not possible).
    """
    invalid = [k for k in indexers
               if k not in data_obj.dims and k not in data_obj._level_coords]
    if invalid:
        raise ValueError("dimensions or multi-index levels %r do not exist"
                         % invalid)

    level_indexers = defaultdict(dict)
    dim_indexers = {}
    for key, label in indexers.items():
        dim, = data_obj[key].dims
        if key != dim:
            # assume here multi-index level indexer
            level_indexers[dim][key] = label
        else:
            dim_indexers[key] = label

    for dim, level_labels in level_indexers.items():
        if dim_indexers.get(dim, False):
            raise ValueError("cannot combine multi-index level indexers "
                             "with an indexer for dimension %s" % dim)
        dim_indexers[dim] = level_labels

    return dim_indexers


def remap_label_indexers(data_obj, indexers, method=None, tolerance=None):
    """Given an xarray data object and label based indexers, return a mapping
    of equivalent location based indexers. Also return a mapping of updated
    pandas index objects (in case of multi-index level drop).
    """
    if method is not None and not isinstance(method, str):
        raise TypeError('``method`` must be a string')

    pos_indexers = {}
    new_indexes = {}

    dim_indexers = get_dim_indexers(data_obj, indexers)
    for dim, label in dim_indexers.items():
        try:
            index = data_obj.indexes[dim]
        except KeyError:
            # no index for this dimension: reuse the provided labels
            if method is not None or tolerance is not None:
                raise ValueError('cannot supply ``method`` or ``tolerance`` '
                                 'when the indexed dimension does not have '
                                 'an associated coordinate.')
            pos_indexers[dim] = label
        else:
            idxr, new_idx = convert_label_indexer(index, label,
                                                  dim, method, tolerance)
            pos_indexers[dim] = idxr
            if new_idx is not None:
                new_indexes[dim] = new_idx

    return pos_indexers, new_indexes


def slice_slice(old_slice, applied_slice, size):
    """Given a slice and the size of the dimension to which it will be applied,
    index it with another slice to return a new slice equivalent to applying
    the slices sequentially
    """
    step = (old_slice.step or 1) * (applied_slice.step or 1)

    # For now, use the hack of turning old_slice into an ndarray to reconstruct
    # the slice start and stop. This is not entirely ideal, but it is still
    # definitely better than leaving the indexer as an array.
    items = _expand_slice(old_slice, size)[applied_slice]
    if len(items) > 0:
        start = items[0]
        stop = items[-1] + int(np.sign(step))
        if stop < 0:
            stop = None
    else:
        start = 0
        stop = 0
    return slice(start, stop, step)


def _index_indexer_1d(old_indexer, applied_indexer, size):
    assert isinstance(applied_indexer, integer_types + (slice, np.ndarray))
    if isinstance(applied_indexer, slice) and applied_indexer == slice(None):
        # shortcut for the usual case
        return old_indexer
    if isinstance(old_indexer, slice):
        if isinstance(applied_indexer, slice):
            indexer = slice_slice(old_indexer, applied_indexer, size)
        else:
            indexer = _expand_slice(old_indexer, size)[applied_indexer]
    else:
        indexer = old_indexer[applied_indexer]
    return indexer


class ExplicitIndexer:
    """Base class for explicit indexer objects.

    ExplicitIndexer objects wrap a tuple of values given by their ``tuple``
    property. These tuples should always have length equal to the number of
    dimensions on the indexed array.

    Do not instantiate BaseIndexer objects directly: instead, use one of the
    sub-classes BasicIndexer, OuterIndexer or VectorizedIndexer.
    """

    def __init__(self, key):
        if type(self) is ExplicitIndexer:  # noqa
            raise TypeError('cannot instantiate base ExplicitIndexer objects')
        self._key = tuple(key)

    @property
    def tuple(self):
        return self._key

    def __repr__(self):
        return '{}({})'.format(type(self).__name__, self.tuple)


def as_integer_or_none(value):
    return None if value is None else operator.index(value)


def as_integer_slice(value):
    start = as_integer_or_none(value.start)
    stop = as_integer_or_none(value.stop)
    step = as_integer_or_none(value.step)
    return slice(start, stop, step)


class BasicIndexer(ExplicitIndexer):
    """Tuple for basic indexing.

    All elements should be int or slice objects. Indexing follows NumPy's
    rules for basic indexing: each axis is independently sliced and axes
    indexed with an integer are dropped from the result.
    """

    def __init__(self, key):
        if not isinstance(key, tuple):
            raise TypeError('key must be a tuple: {!r}'.format(key))

        new_key = []
        for k in key:
            if isinstance(k, integer_types):
                k = int(k)
            elif isinstance(k, slice):
                k = as_integer_slice(k)
            else:
                raise TypeError('unexpected indexer type for {}: {!r}'
                                .format(type(self).__name__, k))
            new_key.append(k)

        super().__init__(new_key)


class OuterIndexer(ExplicitIndexer):
    """Tuple for outer/orthogonal indexing.

    All elements should be int, slice or 1-dimensional np.ndarray objects with
    an integer dtype. Indexing is applied independently along each axis, and
    axes indexed with an integer are dropped from the result. This type of
    indexing works like MATLAB/Fortran.
    """

    def __init__(self, key):
        if not isinstance(key, tuple):
            raise TypeError('key must be a tuple: {!r}'.format(key))

        new_key = []
        for k in key:
            if isinstance(k, integer_types):
                k = int(k)
            elif isinstance(k, slice):
                k = as_integer_slice(k)
            elif isinstance(k, np.ndarray):
                if not np.issubdtype(k.dtype, np.integer):
                    raise TypeError('invalid indexer array, does not have '
                                    'integer dtype: {!r}'.format(k))
                if k.ndim != 1:
                    raise TypeError('invalid indexer array for {}, must have '
                                    'exactly 1 dimension: '
                                    .format(type(self).__name__, k))
                k = np.asarray(k, dtype=np.int64)
            else:
                raise TypeError('unexpected indexer type for {}: {!r}'
                                .format(type(self).__name__, k))
            new_key.append(k)

        super().__init__(new_key)


class VectorizedIndexer(ExplicitIndexer):
    """Tuple for vectorized indexing.

    All elements should be slice or N-dimensional np.ndarray objects with an
    integer dtype and the same number of dimensions. Indexing follows proposed
    rules for np.ndarray.vindex, which matches NumPy's advanced indexing rules
    (including broadcasting) except sliced axes are always moved to the end:
    https://github.com/numpy/numpy/pull/6256
    """

    def __init__(self, key):
        if not isinstance(key, tuple):
            raise TypeError('key must be a tuple: {!r}'.format(key))

        new_key = []
        ndim = None
        for k in key:
            if isinstance(k, slice):
                k = as_integer_slice(k)
            elif isinstance(k, np.ndarray):
                if not np.issubdtype(k.dtype, np.integer):
                    raise TypeError('invalid indexer array, does not have '
                                    'integer dtype: {!r}'.format(k))
                if ndim is None:
                    ndim = k.ndim
                elif ndim != k.ndim:
                    ndims = [k.ndim for k in key if isinstance(k, np.ndarray)]
                    raise ValueError('invalid indexer key: ndarray arguments '
                                     'have different numbers of dimensions: {}'
                                     .format(ndims))
                k = np.asarray(k, dtype=np.int64)
            else:
                raise TypeError('unexpected indexer type for {}: {!r}'
                                .format(type(self).__name__, k))
            new_key.append(k)

        super().__init__(new_key)


class ExplicitlyIndexed:
    """Mixin to mark support for Indexer subclasses in indexing."""


class ExplicitlyIndexedNDArrayMixin(utils.NDArrayMixin, ExplicitlyIndexed):

    def __array__(self, dtype=None):
        key = BasicIndexer((slice(None),) * self.ndim)
        return np.asarray(self[key], dtype=dtype)


class ImplicitToExplicitIndexingAdapter(utils.NDArrayMixin):
    """Wrap an array, converting tuples into the indicated explicit indexer."""

    def __init__(self, array, indexer_cls=BasicIndexer):
        self.array = as_indexable(array)
        self.indexer_cls = indexer_cls

    def __array__(self, dtype=None):
        return np.asarray(self.array, dtype=dtype)

    def __getitem__(self, key):
        key = expanded_indexer(key, self.ndim)
        result = self.array[self.indexer_cls(key)]
        if isinstance(result, ExplicitlyIndexed):
            return type(self)(result, self.indexer_cls)
        else:
            # Sometimes explicitly indexed arrays return NumPy arrays or
            # scalars.
            return result


class LazilyOuterIndexedArray(ExplicitlyIndexedNDArrayMixin):
    """Wrap an array to make basic and outer indexing lazy.
    """

    def __init__(self, array, key=None):
        """
        Parameters
        ----------
        array : array_like
            Array like object to index.
        key : ExplicitIndexer, optional
            Array indexer. If provided, it is assumed to already be in
            canonical expanded form.
        """
        if isinstance(array, type(self)) and key is None:
            # unwrap
            key = array.key
            array = array.array

        if key is None:
            key = BasicIndexer((slice(None),) * array.ndim)

        self.array = as_indexable(array)
        self.key = key

    def _updated_key(self, new_key):
        iter_new_key = iter(expanded_indexer(new_key.tuple, self.ndim))
        full_key = []
        for size, k in zip(self.array.shape, self.key.tuple):
            if isinstance(k, integer_types):
                full_key.append(k)
            else:
                full_key.append(_index_indexer_1d(k, next(iter_new_key), size))
        full_key = tuple(full_key)

        if all(isinstance(k, integer_types + (slice, )) for k in full_key):
            return BasicIndexer(full_key)
        return OuterIndexer(full_key)

    @property
    def shape(self):
        shape = []
        for size, k in zip(self.array.shape, self.key.tuple):
            if isinstance(k, slice):
                shape.append(len(range(*k.indices(size))))
            elif isinstance(k, np.ndarray):
                shape.append(k.size)
        return tuple(shape)

    def __array__(self, dtype=None):
        array = as_indexable(self.array)
        return np.asarray(array[self.key], dtype=None)

    def transpose(self, order):
        return LazilyVectorizedIndexedArray(
            self.array, self.key).transpose(order)

    def __getitem__(self, indexer):
        if isinstance(indexer, VectorizedIndexer):
            array = LazilyVectorizedIndexedArray(self.array, self.key)
            return array[indexer]
        return type(self)(self.array, self._updated_key(indexer))

    def __setitem__(self, key, value):
        if isinstance(key, VectorizedIndexer):
            raise NotImplementedError(
                'Lazy item assignment with the vectorized indexer is not yet '
                'implemented. Load your data first by .load() or compute().')
        full_key = self._updated_key(key)
        self.array[full_key] = value

    def __repr__(self):
        return ('%s(array=%r, key=%r)' %
                (type(self).__name__, self.array, self.key))


class LazilyVectorizedIndexedArray(ExplicitlyIndexedNDArrayMixin):
    """Wrap an array to make vectorized indexing lazy.
    """

    def __init__(self, array, key):
        """
        Parameters
        ----------
        array : array_like
            Array like object to index.
        key : VectorizedIndexer
        """
        if isinstance(key, (BasicIndexer, OuterIndexer)):
            self.key = _outer_to_vectorized_indexer(key, array.shape)
        else:
            self.key = _arrayize_vectorized_indexer(key, array.shape)
        self.array = as_indexable(array)

    @property
    def shape(self):
        return np.broadcast(*self.key.tuple).shape

    def __array__(self, dtype=None):
        return np.asarray(self.array[self.key], dtype=None)

    def _updated_key(self, new_key):
        return _combine_indexers(self.key, self.shape, new_key)

    def __getitem__(self, indexer):
        # If the indexed array becomes a scalar, return LazilyOuterIndexedArray
        if all(isinstance(ind, integer_types) for ind in indexer.tuple):
            key = BasicIndexer(tuple(k[indexer.tuple] for k in self.key.tuple))
            return LazilyOuterIndexedArray(self.array, key)
        return type(self)(self.array, self._updated_key(indexer))

    def transpose(self, order):
        key = VectorizedIndexer(tuple(
            k.transpose(order) for k in self.key.tuple))
        return type(self)(self.array, key)

    def __setitem__(self, key, value):
        raise NotImplementedError(
            'Lazy item assignment with the vectorized indexer is not yet '
            'implemented. Load your data first by .load() or compute().')

    def __repr__(self):
        return ('%s(array=%r, key=%r)' %
                (type(self).__name__, self.array, self.key))


def _wrap_numpy_scalars(array):
    """Wrap NumPy scalars in 0d arrays."""
    if np.isscalar(array):
        return np.array(array)
    else:
        return array


class CopyOnWriteArray(ExplicitlyIndexedNDArrayMixin):
    def __init__(self, array):
        self.array = as_indexable(array)
        self._copied = False

    def _ensure_copied(self):
        if not self._copied:
            self.array = as_indexable(np.array(self.array))
            self._copied = True

    def __array__(self, dtype=None):
        return np.asarray(self.array, dtype=dtype)

    def __getitem__(self, key):
        return type(self)(_wrap_numpy_scalars(self.array[key]))

    def transpose(self, order):
        return self.array.transpose(order)

    def __setitem__(self, key, value):
        self._ensure_copied()
        self.array[key] = value


class MemoryCachedArray(ExplicitlyIndexedNDArrayMixin):
    def __init__(self, array):
        self.array = _wrap_numpy_scalars(as_indexable(array))

    def _ensure_cached(self):
        if not isinstance(self.array, NumpyIndexingAdapter):
            self.array = NumpyIndexingAdapter(np.asarray(self.array))

    def __array__(self, dtype=None):
        self._ensure_cached()
        return np.asarray(self.array, dtype=dtype)

    def __getitem__(self, key):
        return type(self)(_wrap_numpy_scalars(self.array[key]))

    def transpose(self, order):
        return self.array.transpose(order)

    def __setitem__(self, key, value):
        self.array[key] = value


def as_indexable(array):
    """
    This function always returns a ExplicitlyIndexed subclass,
    so that the vectorized indexing is always possible with the returned
    object.
    """
    if isinstance(array, ExplicitlyIndexed):
        return array
    if isinstance(array, np.ndarray):
        return NumpyIndexingAdapter(array)
    if isinstance(array, pd.Index):
        return PandasIndexAdapter(array)
    if isinstance(array, dask_array_type):
        return DaskIndexingAdapter(array)
    raise TypeError('Invalid array type: {}'.format(type(array)))


def _outer_to_vectorized_indexer(key, shape):
    """Convert an OuterIndexer into an vectorized indexer.

    Parameters
    ----------
    key : Outer/Basic Indexer
        An indexer to convert.
    shape : tuple
        Shape of the array subject to the indexing.

    Returns
    -------
    VectorizedIndexer
        Tuple suitable for use to index a NumPy array with vectorized indexing.
        Each element is an array: broadcasting them together gives the shape
        of the result.
    """
    key = key.tuple

    n_dim = len([k for k in key if not isinstance(k, integer_types)])
    i_dim = 0
    new_key = []
    for k, size in zip(key, shape):
        if isinstance(k, integer_types):
            new_key.append(np.array(k).reshape((1,) * n_dim))
        else:  # np.ndarray or slice
            if isinstance(k, slice):
                k = np.arange(*k.indices(size))
            assert k.dtype.kind in {'i', 'u'}
            shape = [(1,) * i_dim + (k.size, ) +
                     (1,) * (n_dim - i_dim - 1)]
            new_key.append(k.reshape(*shape))
            i_dim += 1
    return VectorizedIndexer(tuple(new_key))


def _outer_to_numpy_indexer(key, shape):
    """Convert an OuterIndexer into an indexer for NumPy.

    Parameters
    ----------
    key : Basic/OuterIndexer
        An indexer to convert.
    shape : tuple
        Shape of the array subject to the indexing.

    Returns
    -------
    tuple
        Tuple suitable for use to index a NumPy array.
    """
    if len([k for k in key.tuple if not isinstance(k, slice)]) <= 1:
        # If there is only one vector and all others are slice,
        # it can be safely used in mixed basic/advanced indexing.
        # Boolean index should already be converted to integer array.
        return key.tuple
    else:
        return _outer_to_vectorized_indexer(key, shape).tuple


def _combine_indexers(old_key, shape, new_key):
    """ Combine two indexers.

    Parameters
    ----------
    old_key: ExplicitIndexer
        The first indexer for the original array
    shape: tuple of ints
        Shape of the original array to be indexed by old_key
    new_key:
        The second indexer for indexing original[old_key]
    """
    if not isinstance(old_key, VectorizedIndexer):
        old_key = _outer_to_vectorized_indexer(old_key, shape)
    if len(old_key.tuple) == 0:
        return new_key

    new_shape = np.broadcast(*old_key.tuple).shape
    if isinstance(new_key, VectorizedIndexer):
        new_key = _arrayize_vectorized_indexer(new_key, new_shape)
    else:
        new_key = _outer_to_vectorized_indexer(new_key, new_shape)

    return VectorizedIndexer(tuple(o[new_key.tuple] for o in
                                   np.broadcast_arrays(*old_key.tuple)))


class IndexingSupport:  # could inherit from enum.Enum on Python 3
    # for backends that support only basic indexer
    BASIC = 'BASIC'
    # for backends that support basic / outer indexer
    OUTER = 'OUTER'
    # for backends that support outer indexer including at most 1 vector.
    OUTER_1VECTOR = 'OUTER_1VECTOR'
    # for backends that support full vectorized indexer.
    VECTORIZED = 'VECTORIZED'


def explicit_indexing_adapter(
        key, shape, indexing_support, raw_indexing_method):
    """Support explicit indexing by delegating to a raw indexing method.

    Outer and/or vectorized indexers are supported by indexing a second time
    with a NumPy array.

    Parameters
    ----------
    key : ExplicitIndexer
        Explicit indexing object.
    shape : Tuple[int, ...]
        Shape of the indexed array.
    indexing_support : IndexingSupport enum
        Form of indexing supported by raw_indexing_method.
    raw_indexing_method: callable
        Function (like ndarray.__getitem__) that when called with indexing key
        in the form of a tuple returns an indexed array.

    Returns
    -------
    Indexing result, in the form of a duck numpy-array.
    """
    raw_key, numpy_indices = decompose_indexer(key, shape, indexing_support)
    result = raw_indexing_method(raw_key.tuple)
    if numpy_indices.tuple:
        # index the loaded np.ndarray
        result = NumpyIndexingAdapter(np.asarray(result))[numpy_indices]
    return result


def decompose_indexer(indexer, shape, indexing_support):
    if isinstance(indexer, VectorizedIndexer):
        return _decompose_vectorized_indexer(indexer, shape, indexing_support)
    if isinstance(indexer, (BasicIndexer, OuterIndexer)):
        return _decompose_outer_indexer(indexer, shape, indexing_support)
    raise TypeError('unexpected key type: {}'.format(indexer))


def _decompose_slice(key, size):
    """ convert a slice to successive two slices. The first slice always has
    a positive step.
    """
    start, stop, step = key.indices(size)
    if step > 0:
        # If key already has a positive step, use it as is in the backend
        return key, slice(None)
    else:
        # determine stop precisely for step > 1 case
        # e.g. [98:2:-2] -> [98:3:-2]
        stop = start + int((stop - start - 1) / step) * step + 1
        start, stop = stop + 1, start + 1
        return slice(start, stop, -step), slice(None, None, -1)


def _decompose_vectorized_indexer(indexer, shape, indexing_support):
    """
    Decompose vectorized indexer to the successive two indexers, where the
    first indexer will be used to index backend arrays, while the second one
    is used to index loaded on-memory np.ndarray.

    Parameters
    ----------
    indexer: VectorizedIndexer
    indexing_support: one of IndexerSupport entries

    Returns
    -------
    backend_indexer: OuterIndexer or BasicIndexer
    np_indexers: an ExplicitIndexer (VectorizedIndexer / BasicIndexer)

    Notes
    -----
    This function is used to realize the vectorized indexing for the backend
    arrays that only support basic or outer indexing.

    As an example, let us consider to index a few elements from a backend array
    with a vectorized indexer ([0, 3, 1], [2, 3, 2]).
    Even if the backend array only supports outer indexing, it is more
    efficient to load a subslice of the array than loading the entire array,

    >>> backend_indexer = OuterIndexer([0, 1, 3], [2, 3])
    >>> array = array[backend_indexer]  # load subslice of the array
    >>> np_indexer = VectorizedIndexer([0, 2, 1], [0, 1, 0])
    >>> array[np_indexer]  # vectorized indexing for on-memory np.ndarray.
    """
    assert isinstance(indexer, VectorizedIndexer)

    if indexing_support is IndexingSupport.VECTORIZED:
        return indexer, BasicIndexer(())

    backend_indexer = []
    np_indexer = []
    # convert negative indices
    indexer = [np.where(k < 0, k + s, k) if isinstance(k, np.ndarray) else k
               for k, s in zip(indexer.tuple, shape)]

    for k, s in zip(indexer, shape):
        if isinstance(k, slice):
            # If it is a slice, then we will slice it as-is
            # (but make its step positive) in the backend,
            # and then use all of it (slice(None)) for the in-memory portion.
            bk_slice, np_slice = _decompose_slice(k, s)
            backend_indexer.append(bk_slice)
            np_indexer.append(np_slice)
        else:
            # If it is a (multidimensional) np.ndarray, just pickup the used
            # keys without duplication and store them as a 1d-np.ndarray.
            oind, vind = np.unique(k, return_inverse=True)
            backend_indexer.append(oind)
            np_indexer.append(vind.reshape(*k.shape))

    backend_indexer = OuterIndexer(tuple(backend_indexer))
    np_indexer = VectorizedIndexer(tuple(np_indexer))

    if indexing_support is IndexingSupport.OUTER:
        return backend_indexer, np_indexer

    # If the backend does not support outer indexing,
    # backend_indexer (OuterIndexer) is also decomposed.
    backend_indexer, np_indexer1 = _decompose_outer_indexer(
        backend_indexer, shape, indexing_support)
    np_indexer = _combine_indexers(np_indexer1, shape, np_indexer)
    return backend_indexer, np_indexer


def _decompose_outer_indexer(indexer, shape, indexing_support):
    """
    Decompose outer indexer to the successive two indexers, where the
    first indexer will be used to index backend arrays, while the second one
    is used to index the loaded on-memory np.ndarray.

    Parameters
    ----------
    indexer: VectorizedIndexer
    indexing_support: One of the entries of IndexingSupport

    Returns
    -------
    backend_indexer: OuterIndexer or BasicIndexer
    np_indexers: an ExplicitIndexer (OuterIndexer / BasicIndexer)

    Notes
    -----
    This function is used to realize the vectorized indexing for the backend
    arrays that only support basic or outer indexing.

    As an example, let us consider to index a few elements from a backend array
    with a orthogonal indexer ([0, 3, 1], [2, 3, 2]).
    Even if the backend array only supports basic indexing, it is more
    efficient to load a subslice of the array than loading the entire array,

    >>> backend_indexer = BasicIndexer(slice(0, 3), slice(2, 3))
    >>> array = array[backend_indexer]  # load subslice of the array
    >>> np_indexer = OuterIndexer([0, 2, 1], [0, 1, 0])
    >>> array[np_indexer]  # outer indexing for on-memory np.ndarray.
    """
    if indexing_support == IndexingSupport.VECTORIZED:
        return indexer, BasicIndexer(())
    assert isinstance(indexer, (OuterIndexer, BasicIndexer))

    backend_indexer = []
    np_indexer = []
    # make indexer positive
    pos_indexer = []
    for k, s in zip(indexer.tuple, shape):
        if isinstance(k, np.ndarray):
            pos_indexer.append(np.where(k < 0, k + s, k))
        elif isinstance(k, integer_types) and k < 0:
            pos_indexer.append(k + s)
        else:
            pos_indexer.append(k)
    indexer = pos_indexer

    if indexing_support is IndexingSupport.OUTER_1VECTOR:
        # some backends such as h5py supports only 1 vector in indexers
        # We choose the most efficient axis
        gains = [(np.max(k) - np.min(k) + 1.0) / len(np.unique(k))
                 if isinstance(k, np.ndarray) else 0 for k in indexer]
        array_index = np.argmax(np.array(gains)) if len(gains) > 0 else None

        for i, (k, s) in enumerate(zip(indexer, shape)):
            if isinstance(k, np.ndarray) and i != array_index:
                # np.ndarray key is converted to slice that covers the entire
                # entries of this key.
                backend_indexer.append(slice(np.min(k), np.max(k) + 1))
                np_indexer.append(k - np.min(k))
            elif isinstance(k, np.ndarray):
                # Remove duplicates and sort them in the increasing order
                pkey, ekey = np.unique(k, return_inverse=True)
                backend_indexer.append(pkey)
                np_indexer.append(ekey)
            elif isinstance(k, integer_types):
                backend_indexer.append(k)
            else:  # slice:  convert positive step slice for backend
                bk_slice, np_slice = _decompose_slice(k, s)
                backend_indexer.append(bk_slice)
                np_indexer.append(np_slice)

        return (OuterIndexer(tuple(backend_indexer)),
                OuterIndexer(tuple(np_indexer)))

    if indexing_support == IndexingSupport.OUTER:
        for k, s in zip(indexer, shape):
            if isinstance(k, slice):
                # slice:  convert positive step slice for backend
                bk_slice, np_slice = _decompose_slice(k, s)
                backend_indexer.append(bk_slice)
                np_indexer.append(np_slice)
            elif isinstance(k, integer_types):
                backend_indexer.append(k)
            elif isinstance(k, np.ndarray) and (np.diff(k) >= 0).all():
                backend_indexer.append(k)
                np_indexer.append(slice(None))
            else:
                # Remove duplicates and sort them in the increasing order
                oind, vind = np.unique(k, return_inverse=True)
                backend_indexer.append(oind)
                np_indexer.append(vind.reshape(*k.shape))

        return (OuterIndexer(tuple(backend_indexer)),
                OuterIndexer(tuple(np_indexer)))

    # basic indexer
    assert indexing_support == IndexingSupport.BASIC

    for k, s in zip(indexer, shape):
        if isinstance(k, np.ndarray):
            # np.ndarray key is converted to slice that covers the entire
            # entries of this key.
            backend_indexer.append(slice(np.min(k), np.max(k) + 1))
            np_indexer.append(k - np.min(k))
        elif isinstance(k, integer_types):
            backend_indexer.append(k)
        else:  # slice:  convert positive step slice for backend
            bk_slice, np_slice = _decompose_slice(k, s)
            backend_indexer.append(bk_slice)
            np_indexer.append(np_slice)

    return (BasicIndexer(tuple(backend_indexer)),
            OuterIndexer(tuple(np_indexer)))


def _arrayize_vectorized_indexer(indexer, shape):
    """ Return an identical vindex but slices are replaced by arrays """
    slices = [v for v in indexer.tuple if isinstance(v, slice)]
    if len(slices) == 0:
        return indexer

    arrays = [v for v in indexer.tuple if isinstance(v, np.ndarray)]
    n_dim = arrays[0].ndim if len(arrays) > 0 else 0
    i_dim = 0
    new_key = []
    for v, size in zip(indexer.tuple, shape):
        if isinstance(v, np.ndarray):
            new_key.append(np.reshape(v, v.shape + (1, ) * len(slices)))
        else:  # slice
            shape = ((1,) * (n_dim + i_dim) + (-1,) +
                     (1,) * (len(slices) - i_dim - 1))
            new_key.append(np.arange(*v.indices(size)).reshape(shape))
            i_dim += 1
    return VectorizedIndexer(tuple(new_key))


def _dask_array_with_chunks_hint(array, chunks):
    """Create a dask array using the chunks hint for dimensions of size > 1."""
    import dask.array as da
    if len(chunks) < array.ndim:
        raise ValueError('not enough chunks in hint')
    new_chunks = []
    for chunk, size in zip(chunks, array.shape):
        new_chunks.append(chunk if size > 1 else (1,))
    return da.from_array(array, new_chunks)


def _logical_any(args):
    return functools.reduce(operator.or_, args)


def _masked_result_drop_slice(key, chunks_hint=None):
    key = (k for k in key if not isinstance(k, slice))
    if chunks_hint is not None:
        key = [_dask_array_with_chunks_hint(k, chunks_hint)
               if isinstance(k, np.ndarray) else k
               for k in key]
    return _logical_any(k == -1 for k in key)


def create_mask(indexer, shape, chunks_hint=None):
    """Create a mask for indexing with a fill-value.

    Parameters
    ----------
    indexer : ExplicitIndexer
        Indexer with -1 in integer or ndarray value to indicate locations in
        the result that should be masked.
    shape : tuple
        Shape of the array being indexed.
    chunks_hint : tuple, optional
        Optional tuple indicating desired chunks for the result. If provided,
        used as a hint for chunks on the resulting dask. Must have a hint for
        each dimension on the result array.

    Returns
    -------
    mask : bool, np.ndarray or dask.array.Array with dtype=bool
        Dask array if chunks_hint is provided, otherwise a NumPy array. Has the
        same shape as the indexing result.
    """
    if isinstance(indexer, OuterIndexer):
        key = _outer_to_vectorized_indexer(indexer, shape).tuple
        assert not any(isinstance(k, slice) for k in key)
        mask = _masked_result_drop_slice(key, chunks_hint)

    elif isinstance(indexer, VectorizedIndexer):
        key = indexer.tuple
        base_mask = _masked_result_drop_slice(key, chunks_hint)
        slice_shape = tuple(np.arange(*k.indices(size)).size
                            for k, size in zip(key, shape)
                            if isinstance(k, slice))
        expanded_mask = base_mask[
            (Ellipsis,) + (np.newaxis,) * len(slice_shape)]
        mask = duck_array_ops.broadcast_to(
            expanded_mask, base_mask.shape + slice_shape)

    elif isinstance(indexer, 
```


# xarray/core/variable.py

```
import functools
import itertools
from collections import OrderedDict, defaultdict
from datetime import timedelta
from distutils.version import LooseVersion
from typing import Any, Hashable, Mapping, MutableMapping, Union

import numpy as np
import pandas as pd

import xarray as xr  # only for Dataset and DataArray

from . import (
    arithmetic, common, dtypes, duck_array_ops, indexing, nputils, ops, utils)
from .indexing import (
    BasicIndexer, OuterIndexer, PandasIndexAdapter, VectorizedIndexer,
    as_indexable)
from .options import _get_keep_attrs
from .pycompat import dask_array_type, integer_types
from .utils import (
    OrderedSet, decode_numpy_dict_values, either_dict_or_kwargs,
    ensure_us_time_resolution)

try:
    import dask.array as da
except ImportError:
    pass


NON_NUMPY_SUPPORTED_ARRAY_TYPES = (
    indexing.ExplicitlyIndexed, pd.Index) + dask_array_type
# https://github.com/python/mypy/issues/224
BASIC_INDEXING_TYPES = integer_types + (slice,)  # type: ignore


class MissingDimensionsError(ValueError):
    """Error class used when we can't safely guess a dimension name.
    """
    # inherits from ValueError for backward compatibility
    # TODO: move this to an xarray.exceptions module?


def as_variable(obj, name=None) -> 'Union[Variable, IndexVariable]':
    """Convert an object into a Variable.

    Parameters
    ----------
    obj : object
        Object to convert into a Variable.

        - If the object is already a Variable, return a shallow copy.
        - Otherwise, if the object has 'dims' and 'data' attributes, convert
          it into a new Variable.
        - If all else fails, attempt to convert the object into a Variable by
          unpacking it into the arguments for creating a new Variable.
    name : str, optional
        If provided:

        - `obj` can be a 1D array, which is assumed to label coordinate values
          along a dimension of this given name.
        - Variables with name matching one of their dimensions are converted
          into `IndexVariable` objects.

    Returns
    -------
    var : Variable
        The newly created variable.

    """
    from .dataarray import DataArray

    # TODO: consider extending this method to automatically handle Iris and
    if isinstance(obj, DataArray):
        # extract the primary Variable from DataArrays
        obj = obj.variable

    if isinstance(obj, Variable):
        obj = obj.copy(deep=False)
    elif isinstance(obj, tuple):
        try:
            obj = Variable(*obj)
        except (TypeError, ValueError) as error:
            # use .format() instead of % because it handles tuples consistently
            raise error.__class__('Could not convert tuple of form '
                                  '(dims, data[, attrs, encoding]): '
                                  '{} to Variable.'.format(obj))
    elif utils.is_scalar(obj):
        obj = Variable([], obj)
    elif isinstance(obj, (pd.Index, IndexVariable)) and obj.name is not None:
        obj = Variable(obj.name, obj)
    elif isinstance(obj, (set, dict)):
        raise TypeError(
            "variable %r has invalid type %r" % (name, type(obj)))
    elif name is not None:
        data = as_compatible_data(obj)
        if data.ndim != 1:
            raise MissingDimensionsError(
                'cannot set variable %r with %r-dimensional data '
                'without explicit dimension names. Pass a tuple of '
                '(dims, data) instead.' % (name, data.ndim))
        obj = Variable(name, data, fastpath=True)
    else:
        raise TypeError('unable to convert object into a variable without an '
                        'explicit list of dimensions: %r' % obj)

    if name is not None and name in obj.dims:
        # convert the Variable into an Index
        if obj.ndim != 1:
            raise MissingDimensionsError(
                '%r has more than 1-dimension and the same name as one of its '
                'dimensions %r. xarray disallows such variables because they '
                'conflict with the coordinates used to label '
                'dimensions.' % (name, obj.dims))
        obj = obj.to_index_variable()

    return obj


def _maybe_wrap_data(data):
    """
    Put pandas.Index and numpy.ndarray arguments in adapter objects to ensure
    they can be indexed properly.

    NumpyArrayAdapter, PandasIndexAdapter and LazilyOuterIndexedArray should
    all pass through unmodified.
    """
    if isinstance(data, pd.Index):
        return PandasIndexAdapter(data)
    return data


def _possibly_convert_objects(values):
    """Convert arrays of datetime.datetime and datetime.timedelta objects into
    datetime64 and timedelta64, according to the pandas convention.
    """
    return np.asarray(pd.Series(values.ravel())).reshape(values.shape)


def as_compatible_data(data, fastpath=False):
    """Prepare and wrap data to put in a Variable.

    - If data does not have the necessary attributes, convert it to ndarray.
    - If data has dtype=datetime64, ensure that it has ns precision. If it's a
      pandas.Timestamp, convert it to datetime64.
    - If data is already a pandas or xarray object (other than an Index), just
      use the values.

    Finally, wrap it up with an adapter if necessary.
    """
    if fastpath and getattr(data, 'ndim', 0) > 0:
        # can't use fastpath (yet) for scalars
        return _maybe_wrap_data(data)

    if isinstance(data, Variable):
        return data.data

    if isinstance(data, NON_NUMPY_SUPPORTED_ARRAY_TYPES):
        return _maybe_wrap_data(data)

    if isinstance(data, tuple):
        data = utils.to_0d_object_array(data)

    if isinstance(data, pd.Timestamp):
        # TODO: convert, handle datetime objects, too
        data = np.datetime64(data.value, 'ns')

    if isinstance(data, timedelta):
        data = np.timedelta64(getattr(data, 'value', data), 'ns')

    # we don't want nested self-described arrays
    data = getattr(data, 'values', data)

    if isinstance(data, np.ma.MaskedArray):
        mask = np.ma.getmaskarray(data)
        if mask.any():
            dtype, fill_value = dtypes.maybe_promote(data.dtype)
            data = np.asarray(data, dtype=dtype)
            data[mask] = fill_value
        else:
            data = np.asarray(data)

    # validate whether the data is valid data types
    data = np.asarray(data)

    if isinstance(data, np.ndarray):
        if data.dtype.kind == 'O':
            data = _possibly_convert_objects(data)
        elif data.dtype.kind == 'M':
            data = np.asarray(data, 'datetime64[ns]')
        elif data.dtype.kind == 'm':
            data = np.asarray(data, 'timedelta64[ns]')

    return _maybe_wrap_data(data)


def _as_array_or_item(data):
    """Return the given values as a numpy array, or as an individual item if
    it's a 0d datetime64 or timedelta64 array.

    Importantly, this function does not copy data if it is already an ndarray -
    otherwise, it will not be possible to update Variable values in place.

    This function mostly exists because 0-dimensional ndarrays with
    dtype=datetime64 are broken :(
    https://github.com/numpy/numpy/issues/4337
    https://github.com/numpy/numpy/issues/7619

    TODO: remove this (replace with np.asarray) once these issues are fixed
    """
    data = np.asarray(data)
    if data.ndim == 0:
        if data.dtype.kind == 'M':
            data = np.datetime64(data, 'ns')
        elif data.dtype.kind == 'm':
            data = np.timedelta64(data, 'ns')
    return data


class Variable(common.AbstractArray, arithmetic.SupportsArithmetic,
               utils.NdimSizeLenMixin):
    """A netcdf-like variable consisting of dimensions, data and attributes
    which describe a single Array. A single Variable object is not fully
    described outside the context of its parent Dataset (if you want such a
    fully described object, use a DataArray instead).

    The main functional difference between Variables and numpy arrays is that
    numerical operations on Variables implement array broadcasting by dimension
    name. For example, adding an Variable with dimensions `('time',)` to
    another Variable with dimensions `('space',)` results in a new Variable
    with dimensions `('time', 'space')`. Furthermore, numpy reduce operations
    like ``mean`` or ``sum`` are overwritten to take a "dimension" argument
    instead of an "axis".

    Variables are light-weight objects used as the building block for datasets.
    They are more primitive objects, so operations with them provide marginally
    higher performance than using DataArrays. However, manipulating data in the
    form of a Dataset or DataArray should almost always be preferred, because
    they can use more complete metadata in context of coordinate labels.
    """

    def __init__(self, dims, data, attrs=None, encoding=None, fastpath=False):
        """
        Parameters
        ----------
        dims : str or sequence of str
            Name(s) of the the data dimension(s). Must be either a string (only
            for 1D data) or a sequence of strings with length equal to the
            number of dimensions.
        data : array_like
            Data array which supports numpy-like data access.
        attrs : dict_like or None, optional
            Attributes to assign to the new variable. If None (default), an
            empty attribute dictionary is initialized.
        encoding : dict_like or None, optional
            Dictionary specifying how to encode this array's data into a
            serialized format like netCDF4. Currently used keys (for netCDF)
            include '_FillValue', 'scale_factor', 'add_offset' and 'dtype'.
            Well-behaved code to serialize a Variable should ignore
            unrecognized encoding items.
        """
        self._data = as_compatible_data(data, fastpath=fastpath)
        self._dims = self._parse_dimensions(dims)
        self._attrs = None
        self._encoding = None
        if attrs is not None:
            self.attrs = attrs
        if encoding is not None:
            self.encoding = encoding

    @property
    def dtype(self):
        return self._data.dtype

    @property
    def shape(self):
        return self._data.shape

    @property
    def nbytes(self):
        return self.size * self.dtype.itemsize

    @property
    def _in_memory(self):
        return (isinstance(self._data, (np.ndarray, np.number,
                                        PandasIndexAdapter)) or
                (isinstance(self._data, indexing.MemoryCachedArray) and
                 isinstance(self._data.array, indexing.NumpyIndexingAdapter)))

    @property
    def data(self):
        if isinstance(self._data, dask_array_type):
            return self._data
        else:
            return self.values

    @data.setter
    def data(self, data):
        data = as_compatible_data(data)
        if data.shape != self.shape:
            raise ValueError(
                "replacement data must match the Variable's shape")
        self._data = data

    def load(self, **kwargs):
        """Manually trigger loading of this variable's data from disk or a
        remote source into memory and return this variable.

        Normally, it should not be necessary to call this method in user code,
        because all xarray functions should either work on deferred data or
        load data automatically.

        Parameters
        ----------
        **kwargs : dict
            Additional keyword arguments passed on to ``dask.array.compute``.

        See Also
        --------
        dask.array.compute
        """
        if isinstance(self._data, dask_array_type):
            self._data = as_compatible_data(self._data.compute(**kwargs))
        elif not isinstance(self._data, np.ndarray):
            self._data = np.asarray(self._data)
        return self

    def compute(self, **kwargs):
        """Manually trigger loading of this variable's data from disk or a
        remote source into memory and return a new variable. The original is
        left unaltered.

        Normally, it should not be necessary to call this method in user code,
        because all xarray functions should either work on deferred data or
        load data automatically.

        Parameters
        ----------
        **kwargs : dict
            Additional keyword arguments passed on to ``dask.array.compute``.

        See Also
        --------
        dask.array.compute
        """
        new = self.copy(deep=False)
        return new.load(**kwargs)

    def __dask_graph__(self):
        if isinstance(self._data, dask_array_type):
            return self._data.__dask_graph__()
        else:
            return None

    def __dask_keys__(self):
        return self._data.__dask_keys__()

    def __dask_layers__(self):
        return self._data.__dask_layers__()

    @property
    def __dask_optimize__(self):
        return self._data.__dask_optimize__

    @property
    def __dask_scheduler__(self):
        return self._data.__dask_scheduler__

    def __dask_postcompute__(self):
        array_func, array_args = self._data.__dask_postcompute__()
        return self._dask_finalize, (array_func, array_args, self._dims,
                                     self._attrs, self._encoding)

    def __dask_postpersist__(self):
        array_func, array_args = self._data.__dask_postpersist__()
        return self._dask_finalize, (array_func, array_args, self._dims,
                                     self._attrs, self._encoding)

    @staticmethod
    def _dask_finalize(results, array_func, array_args, dims, attrs, encoding):
        if isinstance(results, dict):  # persist case
            name = array_args[0]
            results = {k: v for k, v in results.items() if k[0] == name}
        data = array_func(results, *array_args)
        return Variable(dims, data, attrs=attrs, encoding=encoding)

    @property
    def values(self):
        """The variable's data as a numpy.ndarray"""
        return _as_array_or_item(self._data)

    @values.setter
    def values(self, values):
        self.data = values

    def to_base_variable(self):
        """Return this variable as a base xarray.Variable"""
        return Variable(self.dims, self._data, self._attrs,
                        encoding=self._encoding, fastpath=True)

    to_variable = utils.alias(to_base_variable, 'to_variable')

    def to_index_variable(self):
        """Return this variable as an xarray.IndexVariable"""
        return IndexVariable(self.dims, self._data, self._attrs,
                             encoding=self._encoding, fastpath=True)

    to_coord = utils.alias(to_index_variable, 'to_coord')

    def to_index(self):
        """Convert this variable to a pandas.Index"""
        return self.to_index_variable().to_index()

    def to_dict(self, data=True):
        """Dictionary representation of variable."""
        item = {'dims': self.dims,
                'attrs': decode_numpy_dict_values(self.attrs)}
        if data:
            item['data'] = ensure_us_time_resolution(self.values).tolist()
        else:
            item.update({'dtype': str(self.dtype), 'shape': self.shape})
        return item

    @property
    def dims(self):
        """Tuple of dimension names with which this variable is associated.
        """
        return self._dims

    @dims.setter
    def dims(self, value):
        self._dims = self._parse_dimensions(value)

    def _parse_dimensions(self, dims):
        if isinstance(dims, str):
            dims = (dims,)
        dims = tuple(dims)
        if len(dims) != self.ndim:
            raise ValueError('dimensions %s must have the same length as the '
                             'number of data dimensions, ndim=%s'
                             % (dims, self.ndim))
        return dims

    def _item_key_to_tuple(self, key):
        if utils.is_dict_like(key):
            return tuple(key.get(dim, slice(None)) for dim in self.dims)
        else:
            return key

    def _broadcast_indexes(self, key):
        """Prepare an indexing key for an indexing operation.

        Parameters
        -----------
        key: int, slice, array, dict or tuple of integer, slices and arrays
            Any valid input for indexing.

        Returns
        -------
        dims: tuple
            Dimension of the resultant variable.
        indexers: IndexingTuple subclass
            Tuple of integer, array-like, or slices to use when indexing
            self._data. The type of this argument indicates the type of
            indexing to perform, either basic, outer or vectorized.
        new_order : Optional[Sequence[int]]
            Optional reordering to do on the result of indexing. If not None,
            the first len(new_order) indexing should be moved to these
            positions.
        """
        key = self._item_key_to_tuple(key)  # key is a tuple
        # key is a tuple of full size
        key = indexing.expanded_indexer(key, self.ndim)
        # Convert a scalar Variable to an integer
        key = tuple(
            k.data.item() if isinstance(k, Variable) and k.ndim == 0 else k
            for k in key)
        # Convert a 0d-array to an integer
        key = tuple(
            k.item() if isinstance(k, np.ndarray) and k.ndim == 0 else k
            for k in key)

        if all(isinstance(k, BASIC_INDEXING_TYPES) for k in key):
            return self._broadcast_indexes_basic(key)

        self._validate_indexers(key)
        # Detect it can be mapped as an outer indexer
        # If all key is unlabeled, or
        # key can be mapped as an OuterIndexer.
        if all(not isinstance(k, Variable) for k in key):
            return self._broadcast_indexes_outer(key)

        # If all key is 1-dimensional and there are no duplicate labels,
        # key can be mapped as an OuterIndexer.
        dims = []
        for k, d in zip(key, self.dims):
            if isinstance(k, Variable):
                if len(k.dims) > 1:
                    return self._broadcast_indexes_vectorized(key)
                dims.append(k.dims[0])
            elif not isinstance(k, integer_types):
                dims.append(d)
        if len(set(dims)) == len(dims):
            return self._broadcast_indexes_outer(key)

        return self._broadcast_indexes_vectorized(key)

    def _broadcast_indexes_basic(self, key):
        dims = tuple(dim for k, dim in zip(key, self.dims)
                     if not isinstance(k, integer_types))
        return dims, BasicIndexer(key), None

    def _validate_indexers(self, key):
        """ Make sanity checks """
        for dim, k in zip(self.dims, key):
            if isinstance(k, BASIC_INDEXING_TYPES):
                pass
            else:
                if not isinstance(k, Variable):
                    k = np.asarray(k)
                    if k.ndim > 1:
                        raise IndexError(
                            "Unlabeled multi-dimensional array cannot be "
                            "used for indexing: {}".format(k))
                if k.dtype.kind == 'b':
                    if self.shape[self.get_axis_num(dim)] != len(k):
                        raise IndexError(
                            "Boolean array size {0:d} is used to index array "
                            "with shape {1:s}.".format(len(k),
                                                       str(self.shape)))
                    if k.ndim > 1:
                        raise IndexError("{}-dimensional boolean indexing is "
                                         "not supported. ".format(k.ndim))
                    if getattr(k, 'dims', (dim, )) != (dim, ):
                        raise IndexError(
                            "Boolean indexer should be unlabeled or on the "
                            "same dimension to the indexed array. Indexer is "
                            "on {0:s} but the target dimension is "
                            "{1:s}.".format(str(k.dims), dim))

    def _broadcast_indexes_outer(self, key):
        dims = tuple(k.dims[0] if isinstance(k, Variable) else dim
                     for k, dim in zip(key, self.dims)
                     if not isinstance(k, integer_types))

        new_key = []
        for k in key:
            if isinstance(k, Variable):
                k = k.data
            if not isinstance(k, BASIC_INDEXING_TYPES):
                k = np.asarray(k)
                if k.dtype.kind == 'b':
                    (k,) = np.nonzero(k)
            new_key.append(k)

        return dims, OuterIndexer(tuple(new_key)), None

    def _nonzero(self):
        """ Equivalent numpy's nonzero but returns a tuple of Varibles. """
        # TODO we should replace dask's native nonzero
        # after https://github.com/dask/dask/issues/1076 is implemented.
        nonzeros = np.nonzero(self.data)
        return tuple(Variable((dim), nz) for nz, dim
                     in zip(nonzeros, self.dims))

    def _broadcast_indexes_vectorized(self, key):
        variables = []
        out_dims_set = OrderedSet()
        for dim, value in zip(self.dims, key):
            if isinstance(value, slice):
                out_dims_set.add(dim)
            else:
                variable = (value if isinstance(value, Variable) else
                            as_variable(value, name=dim))
                if variable.dtype.kind == 'b':  # boolean indexing case
                    (variable,) = variable._nonzero()

                variables.append(variable)
                out_dims_set.update(variable.dims)

        variable_dims = set()
        for variable in variables:
            variable_dims.update(variable.dims)

        slices = []
        for i, (dim, value) in enumerate(zip(self.dims, key)):
            if isinstance(value, slice):
                if dim in variable_dims:
                    # We only convert slice objects to variables if they share
                    # a dimension with at least one other variable. Otherwise,
                    # we can equivalently leave them as slices aknd transpose
                    # the result. This is significantly faster/more efficient
                    # for most array backends.
                    values = np.arange(*value.indices(self.sizes[dim]))
                    variables.insert(i - len(slices), Variable((dim,), values))
                else:
                    slices.append((i, value))

        try:
            variables = _broadcast_compat_variables(*variables)
        except ValueError:
            raise IndexError("Dimensions of indexers mismatch: {}".format(key))

        out_key = [variable.data for variable in variables]
        out_dims = tuple(out_dims_set)
        slice_positions = set()
        for i, value in slices:
            out_key.insert(i, value)
            new_position = out_dims.index(self.dims[i])
            slice_positions.add(new_position)

        if slice_positions:
            new_order = [i for i in range(len(out_dims))
                         if i not in slice_positions]
        else:
            new_order = None

        return out_dims, VectorizedIndexer(tuple(out_key)), new_order

    def __getitem__(self, key):
        """Return a new Array object whose contents are consistent with
        getting the provided key from the underlying data.

        NB. __getitem__ and __setitem__ implement xarray-style indexing,
        where if keys are unlabeled arrays, we index the array orthogonally
        with them. If keys are labeled array (such as Variables), they are
        broadcasted with our usual scheme and then the array is indexed with
        the broadcasted key, like numpy's fancy indexing.

        If you really want to do indexing like `x[x > 0]`, manipulate the numpy
        array `x.values` directly.
        """
        dims, indexer, new_order = self._broadcast_indexes(key)
        data = as_indexable(self._data)[indexer]
        if new_order:
            data = duck_array_ops.moveaxis(
                data, range(len(new_order)), new_order)
        return self._finalize_indexing_result(dims, data)

    def _finalize_indexing_result(self, dims, data):
        """Used by IndexVariable to return IndexVariable objects when possible.
        """
        return type(self)(dims, data, self._attrs, self._encoding,
                          fastpath=True)

    def _getitem_with_mask(self, key, fill_value=dtypes.NA):
        """Index this Variable with -1 remapped to fill_value."""
        # TODO(shoyer): expose this method in public API somewhere (isel?) and
        # use it for reindex.
        # TODO(shoyer): add a sanity check that all other integers are
        # non-negative
        # TODO(shoyer): add an optimization, remapping -1 to an adjacent value
        # that is actually indexed rather than mapping it to the last value
        # along each axis.

        if fill_value is dtypes.NA:
            fill_value = dtypes.get_fill_value(self.dtype)

        dims, indexer, new_order = self._broadcast_indexes(key)

        if self.size:
            if isinstance(self._data, dask_array_type):
                # dask's indexing is faster this way; also vindex does not
                # support negative indices yet:
                # https://github.com/dask/dask/pull/2967
                actual_indexer = indexing.posify_mask_indexer(indexer)
            else:
                actual_indexer = indexer

            data = as_indexable(self._data)[actual_indexer]
            chunks_hint = getattr(data, 'chunks', None)
            mask = indexing.create_mask(indexer, self.shape, chunks_hint)
            data = duck_array_ops.where(mask, fill_value, data)
        else:
            # array cannot be indexed along dimensions of size 0, so just
            # build the mask directly instead.
            mask = indexing.create_mask(indexer, self.shape)
            data = np.broadcast_to(fill_value, getattr(mask, 'shape', ()))

        if new_order:
            data = duck_array_ops.moveaxis(
                data, range(len(new_order)), new_order)
        return self._finalize_indexing_result(dims, data)

    def __setitem__(self, key, value):
        """__setitem__ is overloaded to access the underlying numpy values with
        orthogonal indexing.

        See __getitem__ for more details.
        """
        dims, index_tuple, new_order = self._broadcast_indexes(key)

        if not isinstance(value, Variable):
            value = as_compatible_data(value)
            if value.ndim > len(dims):
                raise ValueError(
                    'shape mismatch: value array of shape %s could not be '
                    'broadcast to indexing result with %s dimensions'
                    % (value.shape, len(dims)))
            if value.ndim == 0:
                value = Variable((), value)
            else:
                value = Variable(dims[-value.ndim:], value)
        # broadcast to become assignable
        value = value.set_dims(dims).data

        if new_order:
            value = duck_array_ops.asarray(value)
            value = value[(len(dims) - value.ndim) * (np.newaxis,) +
                          (Ellipsis,)]
            value = duck_array_ops.moveaxis(
                value, new_order, range(len(new_order)))

        indexable = as_indexable(self._data)
        indexable[index_tuple] = value

    @property
    def attrs(self) -> 'OrderedDict[Any, Any]':
        """Dictionary of local attributes on this variable.
        """
        if self._attrs is None:
            self._attrs = OrderedDict()
        return self._attrs

    @attrs.setter
    def attrs(self, value: Mapping[Hashable, Any]) -> None:
        self._attrs = OrderedDict(value)

    @property
    def encoding(self):
        """Dictionary of encodings on this variable.
        """
        if self._encoding is None:
            self._encoding = {}
        return self._encoding

    @encoding.setter
    def encoding(self, value):
        try:
            self._encoding = dict(value)
        except ValueError:
            raise ValueError('encoding must be castable to a dictionary')

    def copy(self, deep=True, data=None):
        """Returns a copy of this object.

        If `deep=True`, the data array is loaded into memory and copied onto
        the new object. Dimensions, attributes and encodings are always copied.

        Use `data` to create a new object with the same structure as
        original but entirely new data.

        Parameters
        ----------
        deep : bool, optional
            Whether the data array is loaded into memory and copied onto
            the new object. Default is True.
        data : array_like, optional
            Data to use in the new object. Must have same shape as original.
            When `data` is used, `deep` is ignored.

        Returns
        -------
        object : Variable
            New object with dimensions, attributes, encodings, and optionally
            data copied from original.

        Examples
        --------

        Shallow copy versus deep copy

        >>> var = xr.Variable(data=[1, 2, 3], dims='x')
        >>> var.copy()
        <xarray.Variable (x: 3)>
        array([1, 2, 3])
        >>> var_0 = var.copy(deep=False)
        >>> var_0[0] = 7
        >>> var_0
        <xarray.Variable (x: 3)>
        array([7, 2, 3])
        >>> var
        <xarray.Variable (x: 3)>
        array([7, 2, 3])

        Changing the data using the ``data`` argument maintains the
        structure of the original object, but with the new data. Original
        object is unaffected.

        >>> var.copy(data=[0.1, 0.2, 0.3])
        <xarray.Variable (x: 3)>
        array([ 0.1,  0.2,  0.3])
        >>> var
        <xarray.Variable (x: 3)>
        array([7, 2, 3])

        See Also
        --------
        pandas.DataFrame.copy
        """
        if data is None:
            data = self._data

            if isinstance(data, indexing.MemoryCachedArray):
                # don't share caching between copies
                data = indexing.MemoryCachedArray(data.array)

            if deep:
                if isinstance(data, dask_array_type):
                    data = data.copy()
                elif not isinstance(data, PandasIndexAdapter):
                    # pandas.Index is immutable
                    data = np.array(data)
        else:
            data = as_compatible_data(data)
            if self.shape != data.shape:
                raise ValueError("Data shape {} must match shape of object {}"
                                 .format(data.shape, self.shape))

        # note:
        # dims is already an immutable tuple
        # attributes and encoding will be copied when the new Array is created
        return type(self)(self.dims, data, self._attrs, self._encoding,
                          fastpath=True)

    def __copy__(self):
        return self.copy(deep=False)

    def __deepcopy__(self, memo=None):
        # memo does nothing but is required for compatibility with
        # copy.deepcopy
        return self.copy(deep=True)

    # mutable objects should not be hashable
    # https://github.com/python/mypy/issues/4266
    __hash__ = None  # type: ignore

    @property
    def chunks(self):
        """Block dimensions for this array's data or None if it's not a dask
        array.
        """
        return getattr(self._data, 'chunks', None)

    _array_counter = itertools.count()

    def chunk(self, chunks=None, name=None, lock=False):
        """Coerce this array's data into a dask arrays with the given chunks.

        If this variable is a non-dask array, it will be converted to dask
        array. If it's a dask array, it will be rechunked to the given chunk
        sizes.

        If neither chunks is not provided for one or more dimensions, chunk
        sizes along that dimension will not be updated; non-dask arrays will be
        converted into dask arrays with a single block.

        Parameters
        ----------
        chunks : int, tuple or dict, optional
            Chunk sizes along each dimension, e.g., ``5``, ``(5, 5)`` or
            ``{'x': 5, 'y': 5}``.
        name : str, optional
            Used to generate the name for this array in the internal dask
            graph. Does not need not be unique.
        lock : optional
            Passed on to :py:func:`dask.array.from_array`, if the array is not
            already as dask array.

        Returns
        -------
        chunked : xarray.Variable
        """
        import dask
        import dask.array as da

        if utils.is_dict_like(chunks):
            chunks = dict((self.get_axis_num(dim), chunk)
                          for dim, chunk in chunks.items())

        if chunks is None:
            chunks = self.chunks or self.shape

        data = self._data
        if isinstance(data, da.Array):
            data = data.rechunk(chunks)
        else:
            if utils.is_dict_like(chunks):
                chunks = tuple(chunks.get(n, s)
                               for n, s in enumerate(self.shape))
            # da.from_array works by using lazily indexing with a tuple of
            # slices. Using OuterIndexer is a pragmatic choice: dask does not
            # yet handle different indexing types in an explicit way:
            # https://github.com/dask/dask/issues/2883
            data = indexing.ImplicitToExplicitIndexingAdapter(
                data, indexing.OuterIndexer)

            # For now, assume that all arrays that we wrap with dask (including
            # our lazily loaded backend array classes) should use NumPy array
            # operations.
            if LooseVersion(dask.__version__) > '1.2.2':
                kwargs = dict(meta=np.ndarray)
            else:
                kwargs = dict()

            data = da.from_array(
                data, chunks, name=name, lock=lock, **kwargs)

        return type(self)(self.dims, data, self._attrs, self._encoding,
                          fastpath=True)

    def isel(self, indexers=None, drop=False, **indexers_kwargs):
        """Return a new array indexed along the specified dimension(s).

        Parameters
        ----------
        **indexers : {dim: indexer, ...}
            Keyword arguments with names matching dimensions and values given
            by integers, slice objects or arrays.

        Returns
        -------
        obj : Array object
            A new Array with the selected data and dimensions. In general,
            the new variable's data will be a view of this variable's data,
            unless numpy fancy indexing was triggered by using an array
            indexer, in which case the data will be a copy.
        """
        indexers = either_dict_or_kwargs(indexers, indexers_kwargs, 'isel')

        invalid = [k for k in indexers if k not in self.dims]
        if invalid:
            raise ValueError("dimensions %r do not exist" % invalid)

        key = [slice(None)] * self.ndim
        for i, dim in enumerate(self.dims):
            if dim in indexers:
                key[i] = indexers[dim]
        return self[tuple(key)]

    def squeeze(self, dim=None):
        """Return a new object with squeezed data.

        Parameters
        ----------
        dim : None or str or tuple of str, optional
            Selects a subset of the length one dimensions. If a dimension is
            selected with length greater than one, an error is raised. If
            None, all length one dimensions are squeezed.

        Returns
        -------
        squeezed : same type as caller
            This object, but with with all or a subset of the dimensions of
            length 1 removed.

        See Also
        --------
        numpy.squeeze
        """
        dims = common.get_squeeze_dims(self, dim)
        return self.isel({d: 0 for d in dims})

    def _shift_one_dim(self, dim, count, fill_value=dtypes.NA):
        axis = self.get_axis_num(dim)

        if count > 0:
            keep = slice(None, -count)
        elif count < 0:
            keep = slice(-count, None)
        else:
            keep = slice(None)

        trimmed_data = self[(slice(None),) * axis + (keep,)].data

        if fill_value is dtypes.NA:
            dtype, fill_value = dtypes.maybe_promote(self.dtype)
        else:
            dtype = self.dtype

        shape = list(self.shape)
        shape[axis] = min(abs(count), shape[axis])

        if isinstance(trimmed_data, dask_array_type):
            chunks = list(trimmed_data.chunks)
            chunks[axis] = (shape[axis],)
            full = functools.partial(da.full, chunks=chunks)
        else:
            full = np.full

        filler = full(shape, fill_value, dtype=dtype)

        if count > 0:
            arrays = [filler, trimmed_data]
        else:
            arrays = [trimmed_data, filler]

        data = duck_array_ops.concatenate(arrays, axis)

        if isinstance(data, dask_array_type):
            # chunked data should come out with the same chunks; this makes
            # it feasible to combine shifted and unshifted data
            # TODO: remove this once dask.array automatically aligns chunks
            data = data.rechunk(self.data.chunks)

        return type(self)(self.dims, data, self._attrs, fastpath=True)

    def shift(self, shifts=None, fill_value=dtypes.NA, **shifts_kwargs):
        """
        Return a new Variable with shifted data.

        Parameters
        ----------
        shifts : mapping of the form {dim: offset}
            Integer offset to shift along each of the given dimensions.
            Positive offsets shift to the right; negative offsets shift to the
            left.
        fill_value: scalar, optional
            Value to use for newly missing values
        **shifts_kwargs:
            The keyword arguments form of ``shifts``.
            One of shifts or shifts_kwarg must be provided.

        Returns
        -------
        shifted : Variable
            Variable with the same dimensions and attributes but shifted data.
        """
        shifts = either_dict_or_kwargs(shifts, shifts_kwargs, 'shift')
        result = self
        for dim, count in shifts.items():
            result = result._shift_one_dim(dim, count, fill_value=fill_value)
        return result

    def pad_with_fill_value(self, pad_widths=None, fill_value=dtypes.NA,
                            **pad_widths_kwargs):
        """
        Return a new Variable with paddings.

        Parameters
        ----------
        pad_width: Mapping of the form {dim: (before, after)}
            Number of values padded to the edges of each dimension.
        **pad_widths_kwargs:
            Keyword argument for pad_widths
        """
        pad_widths = either_dict_or_kwargs(pad_widths, pad_widths_kwargs,
                                           'pad')

        if fill_value is dtypes.NA:
            dtype, fill_value = dtypes.maybe_promote(self.dtype)
        else:
            dtype = self.dtype

        if isinstance(self.data, dask_array_type):
            array = self.data

            # Dask does not yet support pad. We manually implement it.
            # https://github.com/dask/dask/issues/1926
            for d, pad in pad_widths.items():
                axis = self.get_axis_num(d)
                before_shape = list(array.shape)
                before_shape[axis] = pad[0]
                before_chunks = list(array.chunks)
                before_chunks[axis] = (pad[0], )
                after_shape = list(array.shape)
                after_shape[axis] = pad[1]
                after_chunks = list(array.chunks)
                after_chunks[axis] = (pad[1], )

                arrays = []
                if pad[0] > 0:
                    arrays.append(da.full(before_shape, fill_value,
                                          dtype=dtype, chunks=before_ch
```


# xarray/tests/test_variable.py

```
import warnings
from collections import OrderedDict
from copy import copy, deepcopy
from datetime import datetime, timedelta
from distutils.version import LooseVersion
from textwrap import dedent

import numpy as np
import pandas as pd
import pytest
import pytz

from xarray import Coordinate, Dataset, IndexVariable, Variable, set_options
from xarray.core import dtypes, indexing
from xarray.core.common import full_like, ones_like, zeros_like
from xarray.core.indexing import (
    BasicIndexer, CopyOnWriteArray, DaskIndexingAdapter,
    LazilyOuterIndexedArray, MemoryCachedArray, NumpyIndexingAdapter,
    OuterIndexer, PandasIndexAdapter, VectorizedIndexer)
from xarray.core.utils import NDArrayMixin
from xarray.core.variable import as_compatible_data, as_variable
from xarray.tests import requires_bottleneck

from . import (
    assert_allclose, assert_array_equal, assert_equal, assert_identical,
    raises_regex, requires_dask, source_ndarray)


class VariableSubclassobjects:
    def test_properties(self):
        data = 0.5 * np.arange(10)
        v = self.cls(['time'], data, {'foo': 'bar'})
        assert v.dims == ('time',)
        assert_array_equal(v.values, data)
        assert v.dtype == float
        assert v.shape == (10,)
        assert v.size == 10
        assert v.sizes == {'time': 10}
        assert v.nbytes == 80
        assert v.ndim == 1
        assert len(v) == 10
        assert v.attrs == {'foo': 'bar'}

    def test_attrs(self):
        v = self.cls(['time'], 0.5 * np.arange(10))
        assert v.attrs == {}
        attrs = {'foo': 'bar'}
        v.attrs = attrs
        assert v.attrs == attrs
        assert isinstance(v.attrs, OrderedDict)
        v.attrs['foo'] = 'baz'
        assert v.attrs['foo'] == 'baz'

    def test_getitem_dict(self):
        v = self.cls(['x'], np.random.randn(5))
        actual = v[{'x': 0}]
        expected = v[0]
        assert_identical(expected, actual)

    def test_getitem_1d(self):
        data = np.array([0, 1, 2])
        v = self.cls(['x'], data)

        v_new = v[dict(x=[0, 1])]
        assert v_new.dims == ('x', )
        assert_array_equal(v_new, data[[0, 1]])

        v_new = v[dict(x=slice(None))]
        assert v_new.dims == ('x', )
        assert_array_equal(v_new, data)

        v_new = v[dict(x=Variable('a', [0, 1]))]
        assert v_new.dims == ('a', )
        assert_array_equal(v_new, data[[0, 1]])

        v_new = v[dict(x=1)]
        assert v_new.dims == ()
        assert_array_equal(v_new, data[1])

        # tuple argument
        v_new = v[slice(None)]
        assert v_new.dims == ('x', )
        assert_array_equal(v_new, data)

    def test_getitem_1d_fancy(self):
        v = self.cls(['x'], [0, 1, 2])
        # 1d-variable should be indexable by multi-dimensional Variable
        ind = Variable(('a', 'b'), [[0, 1], [0, 1]])
        v_new = v[ind]
        assert v_new.dims == ('a', 'b')
        expected = np.array(v._data)[([0, 1], [0, 1]), ]
        assert_array_equal(v_new, expected)

        # boolean indexing
        ind = Variable(('x', ), [True, False, True])
        v_new = v[ind]
        assert_identical(v[[0, 2]], v_new)
        v_new = v[[True, False, True]]
        assert_identical(v[[0, 2]], v_new)

        with raises_regex(IndexError, "Boolean indexer should"):
            ind = Variable(('a', ), [True, False, True])
            v[ind]

    def test_getitem_with_mask(self):
        v = self.cls(['x'], [0, 1, 2])
        assert_identical(v._getitem_with_mask(-1), Variable((), np.nan))
        assert_identical(v._getitem_with_mask([0, -1, 1]),
                         self.cls(['x'], [0, np.nan, 1]))
        assert_identical(v._getitem_with_mask(slice(2)),
                         self.cls(['x'], [0, 1]))
        assert_identical(v._getitem_with_mask([0, -1, 1], fill_value=-99),
                         self.cls(['x'], [0, -99, 1]))

    def test_getitem_with_mask_size_zero(self):
        v = self.cls(['x'], [])
        assert_identical(v._getitem_with_mask(-1), Variable((), np.nan))
        assert_identical(v._getitem_with_mask([-1, -1, -1]),
                         self.cls(['x'], [np.nan, np.nan, np.nan]))

    def test_getitem_with_mask_nd_indexer(self):
        v = self.cls(['x'], [0, 1, 2])
        indexer = Variable(('x', 'y'), [[0, -1], [-1, 2]])
        assert_identical(v._getitem_with_mask(indexer, fill_value=-1), indexer)

    def _assertIndexedLikeNDArray(self, variable, expected_value0,
                                  expected_dtype=None):
        """Given a 1-dimensional variable, verify that the variable is indexed
        like a numpy.ndarray.
        """
        assert variable[0].shape == ()
        assert variable[0].ndim == 0
        assert variable[0].size == 1
        # test identity
        assert variable.equals(variable.copy())
        assert variable.identical(variable.copy())
        # check value is equal for both ndarray and Variable
        with warnings.catch_warnings():
            warnings.filterwarnings('ignore', "In the future, 'NAT == x'")
            np.testing.assert_equal(variable.values[0], expected_value0)
            np.testing.assert_equal(variable[0].values, expected_value0)
        # check type or dtype is consistent for both ndarray and Variable
        if expected_dtype is None:
            # check output type instead of array dtype
            assert type(variable.values[0]) == type(expected_value0)
            assert type(variable[0].values) == type(expected_value0)
        elif expected_dtype is not False:
            assert variable.values[0].dtype == expected_dtype
            assert variable[0].values.dtype == expected_dtype

    def test_index_0d_int(self):
        for value, dtype in [(0, np.int_),
                             (np.int32(0), np.int32)]:
            x = self.cls(['x'], [value])
            self._assertIndexedLikeNDArray(x, value, dtype)

    def test_index_0d_float(self):
        for value, dtype in [(0.5, np.float_),
                             (np.float32(0.5), np.float32)]:
            x = self.cls(['x'], [value])
            self._assertIndexedLikeNDArray(x, value, dtype)

    def test_index_0d_string(self):
        value = 'foo'
        dtype = np.dtype('U3')
        x = self.cls(['x'], [value])
        self._assertIndexedLikeNDArray(x, value, dtype)

    def test_index_0d_datetime(self):
        d = datetime(2000, 1, 1)
        x = self.cls(['x'], [d])
        self._assertIndexedLikeNDArray(x, np.datetime64(d))

        x = self.cls(['x'], [np.datetime64(d)])
        self._assertIndexedLikeNDArray(x, np.datetime64(d), 'datetime64[ns]')

        x = self.cls(['x'], pd.DatetimeIndex([d]))
        self._assertIndexedLikeNDArray(x, np.datetime64(d), 'datetime64[ns]')

    def test_index_0d_timedelta64(self):
        td = timedelta(hours=1)

        x = self.cls(['x'], [np.timedelta64(td)])
        self._assertIndexedLikeNDArray(
            x, np.timedelta64(td), 'timedelta64[ns]')

        x = self.cls(['x'], pd.to_timedelta([td]))
        self._assertIndexedLikeNDArray(
            x, np.timedelta64(td), 'timedelta64[ns]')

    def test_index_0d_not_a_time(self):
        d = np.datetime64('NaT', 'ns')
        x = self.cls(['x'], [d])
        self._assertIndexedLikeNDArray(x, d)

    def test_index_0d_object(self):

        class HashableItemWrapper:
            def __init__(self, item):
                self.item = item

            def __eq__(self, other):
                return self.item == other.item

            def __hash__(self):
                return hash(self.item)

            def __repr__(self):
                return '%s(item=%r)' % (type(self).__name__, self.item)

        item = HashableItemWrapper((1, 2, 3))
        x = self.cls('x', [item])
        self._assertIndexedLikeNDArray(x, item, expected_dtype=False)

    def test_0d_object_array_with_list(self):
        listarray = np.empty((1,), dtype=object)
        listarray[0] = [1, 2, 3]
        x = self.cls('x', listarray)
        assert_array_equal(x.data, listarray)
        assert_array_equal(x[0].data, listarray.squeeze())
        assert_array_equal(x.squeeze().data, listarray.squeeze())

    def test_index_and_concat_datetime(self):
        # regression test for #125
        date_range = pd.date_range('2011-09-01', periods=10)
        for dates in [date_range, date_range.values,
                      date_range.to_pydatetime()]:
            expected = self.cls('t', dates)
            for times in [[expected[i] for i in range(10)],
                          [expected[i:(i + 1)] for i in range(10)],
                          [expected[[i]] for i in range(10)]]:
                actual = Variable.concat(times, 't')
                assert expected.dtype == actual.dtype
                assert_array_equal(expected, actual)

    def test_0d_time_data(self):
        # regression test for #105
        x = self.cls('time', pd.date_range('2000-01-01', periods=5))
        expected = np.datetime64('2000-01-01', 'ns')
        assert x[0].values == expected

    def test_datetime64_conversion(self):
        times = pd.date_range('2000-01-01', periods=3)
        for values, preserve_source in [
            (times, True),
            (times.values, True),
            (times.values.astype('datetime64[s]'), False),
            (times.to_pydatetime(), False),
        ]:
            v = self.cls(['t'], values)
            assert v.dtype == np.dtype('datetime64[ns]')
            assert_array_equal(v.values, times.values)
            assert v.values.dtype == np.dtype('datetime64[ns]')
            same_source = source_ndarray(v.values) is source_ndarray(values)
            assert preserve_source == same_source

    def test_timedelta64_conversion(self):
        times = pd.timedelta_range(start=0, periods=3)
        for values, preserve_source in [
            (times, True),
            (times.values, True),
            (times.values.astype('timedelta64[s]'), False),
            (times.to_pytimedelta(), False),
        ]:
            v = self.cls(['t'], values)
            assert v.dtype == np.dtype('timedelta64[ns]')
            assert_array_equal(v.values, times.values)
            assert v.values.dtype == np.dtype('timedelta64[ns]')
            same_source = source_ndarray(v.values) is source_ndarray(values)
            assert preserve_source == same_source

    def test_object_conversion(self):
        data = np.arange(5).astype(str).astype(object)
        actual = self.cls('x', data)
        assert actual.dtype == data.dtype

    def test_pandas_data(self):
        v = self.cls(['x'], pd.Series([0, 1, 2], index=[3, 2, 1]))
        assert_identical(v, v[[0, 1, 2]])
        v = self.cls(['x'], pd.Index([0, 1, 2]))
        assert v[0].values == v.values[0]

    def test_pandas_period_index(self):
        v = self.cls(['x'], pd.period_range(start='2000', periods=20,
                                            freq='B'))
        v = v.load()  # for dask-based Variable
        assert v[0] == pd.Period('2000', freq='B')
        assert "Period('2000-01-03', 'B')" in repr(v)

    def test_1d_math(self):
        x = 1.0 * np.arange(5)
        y = np.ones(5)

        # should we need `.to_base_variable()`?
        # probably a break that `+v` changes type?
        v = self.cls(['x'], x)
        base_v = v.to_base_variable()
        # unary ops
        assert_identical(base_v, +v)
        assert_identical(base_v, abs(v))
        assert_array_equal((-v).values, -x)
        # binary ops with numbers
        assert_identical(base_v, v + 0)
        assert_identical(base_v, 0 + v)
        assert_identical(base_v, v * 1)
        # binary ops with numpy arrays
        assert_array_equal((v * x).values, x ** 2)
        assert_array_equal((x * v).values, x ** 2)
        assert_array_equal(v - y, v - 1)
        assert_array_equal(y - v, 1 - v)
        # verify attributes are dropped
        v2 = self.cls(['x'], x, {'units': 'meters'})
        assert_identical(base_v, +v2)
        # binary ops with all variables
        assert_array_equal(v + v, 2 * v)
        w = self.cls(['x'], y, {'foo': 'bar'})
        assert_identical(v + w, self.cls(['x'], x + y).to_base_variable())
        assert_array_equal((v * w).values, x * y)

        # something complicated
        assert_array_equal((v ** 2 * w - 1 + x).values, x ** 2 * y - 1 + x)
        # make sure dtype is preserved (for Index objects)
        assert float == (+v).dtype
        assert float == (+v).values.dtype
        assert float == (0 + v).dtype
        assert float == (0 + v).values.dtype
        # check types of returned data
        assert isinstance(+v, Variable)
        assert not isinstance(+v, IndexVariable)
        assert isinstance(0 + v, Variable)
        assert not isinstance(0 + v, IndexVariable)

    def test_1d_reduce(self):
        x = np.arange(5)
        v = self.cls(['x'], x)
        actual = v.sum()
        expected = Variable((), 10)
        assert_identical(expected, actual)
        assert type(actual) is Variable

    def test_array_interface(self):
        x = np.arange(5)
        v = self.cls(['x'], x)
        assert_array_equal(np.asarray(v), x)
        # test patched in methods
        assert_array_equal(v.astype(float), x.astype(float))
        # think this is a break, that argsort changes the type
        assert_identical(v.argsort(), v.to_base_variable())
        assert_identical(v.clip(2, 3),
                         self.cls('x', x.clip(2, 3)).to_base_variable())
        # test ufuncs
        assert_identical(np.sin(v),
                         self.cls(['x'], np.sin(x)).to_base_variable())
        assert isinstance(np.sin(v), Variable)
        assert not isinstance(np.sin(v), IndexVariable)

    def example_1d_objects(self):
        for data in [range(3),
                     0.5 * np.arange(3),
                     0.5 * np.arange(3, dtype=np.float32),
                     pd.date_range('2000-01-01', periods=3),
                     np.array(['a', 'b', 'c'], dtype=object)]:
            yield (self.cls('x', data), data)

    def test___array__(self):
        for v, data in self.example_1d_objects():
            assert_array_equal(v.values, np.asarray(data))
            assert_array_equal(np.asarray(v), np.asarray(data))
            assert v[0].values == np.asarray(data)[0]
            assert np.asarray(v[0]) == np.asarray(data)[0]

    def test_equals_all_dtypes(self):
        for v, _ in self.example_1d_objects():
            v2 = v.copy()
            assert v.equals(v2)
            assert v.identical(v2)
            assert v.no_conflicts(v2)
            assert v[0].equals(v2[0])
            assert v[0].identical(v2[0])
            assert v[0].no_conflicts(v2[0])
            assert v[:2].equals(v2[:2])
            assert v[:2].identical(v2[:2])
            assert v[:2].no_conflicts(v2[:2])

    def test_eq_all_dtypes(self):
        # ensure that we don't choke on comparisons for which numpy returns
        # scalars
        expected = Variable('x', 3 * [False])
        for v, _ in self.example_1d_objects():
            actual = 'z' == v
            assert_identical(expected, actual)
            actual = ~('z' != v)
            assert_identical(expected, actual)

    def test_encoding_preserved(self):
        expected = self.cls('x', range(3), {'foo': 1}, {'bar': 2})
        for actual in [expected.T,
                       expected[...],
                       expected.squeeze(),
                       expected.isel(x=slice(None)),
                       expected.set_dims({'x': 3}),
                       expected.copy(deep=True),
                       expected.copy(deep=False)]:

            assert_identical(expected.to_base_variable(),
                             actual.to_base_variable())
            assert expected.encoding == actual.encoding

    def test_concat(self):
        x = np.arange(5)
        y = np.arange(5, 10)
        v = self.cls(['a'], x)
        w = self.cls(['a'], y)
        assert_identical(Variable(['b', 'a'], np.array([x, y])),
                         Variable.concat([v, w], 'b'))
        assert_identical(Variable(['b', 'a'], np.array([x, y])),
                         Variable.concat((v, w), 'b'))
        assert_identical(Variable(['b', 'a'], np.array([x, y])),
                         Variable.concat((v, w), 'b'))
        with raises_regex(ValueError, 'inconsistent dimensions'):
            Variable.concat([v, Variable(['c'], y)], 'b')
        # test indexers
        actual = Variable.concat(
            [v, w],
            positions=[np.arange(0, 10, 2), np.arange(1, 10, 2)],
            dim='a')
        expected = Variable('a', np.array([x, y]).ravel(order='F'))
        assert_identical(expected, actual)
        # test concatenating along a dimension
        v = Variable(['time', 'x'], np.random.random((10, 8)))
        assert_identical(v, Variable.concat([v[:5], v[5:]], 'time'))
        assert_identical(v, Variable.concat([v[:5], v[5:6], v[6:]], 'time'))
        assert_identical(v, Variable.concat([v[:1], v[1:]], 'time'))
        # test dimension order
        assert_identical(v, Variable.concat([v[:, :5], v[:, 5:]], 'x'))
        with raises_regex(ValueError, 'all input arrays must have'):
            Variable.concat([v[:, 0], v[:, 1:]], 'x')

    def test_concat_attrs(self):
        # different or conflicting attributes should be removed
        v = self.cls('a', np.arange(5), {'foo': 'bar'})
        w = self.cls('a', np.ones(5))
        expected = self.cls(
            'a', np.concatenate([np.arange(5), np.ones(5)])).to_base_variable()
        assert_identical(expected, Variable.concat([v, w], 'a'))
        w.attrs['foo'] = 2
        assert_identical(expected, Variable.concat([v, w], 'a'))
        w.attrs['foo'] = 'bar'
        expected.attrs['foo'] = 'bar'
        assert_identical(expected, Variable.concat([v, w], 'a'))

    def test_concat_fixed_len_str(self):
        # regression test for #217
        for kind in ['S', 'U']:
            x = self.cls('animal', np.array(['horse'], dtype=kind))
            y = self.cls('animal', np.array(['aardvark'], dtype=kind))
            actual = Variable.concat([x, y], 'animal')
            expected = Variable(
                'animal', np.array(['horse', 'aardvark'], dtype=kind))
            assert_equal(expected, actual)

    def test_concat_number_strings(self):
        # regression test for #305
        a = self.cls('x', ['0', '1', '2'])
        b = self.cls('x', ['3', '4'])
        actual = Variable.concat([a, b], dim='x')
        expected = Variable('x', np.arange(5).astype(str))
        assert_identical(expected, actual)
        assert actual.dtype.kind == expected.dtype.kind

    def test_concat_mixed_dtypes(self):
        a = self.cls('x', [0, 1])
        b = self.cls('x', ['two'])
        actual = Variable.concat([a, b], dim='x')
        expected = Variable('x', np.array([0, 1, 'two'], dtype=object))
        assert_identical(expected, actual)
        assert actual.dtype == object

    @pytest.mark.parametrize('deep', [True, False])
    def test_copy(self, deep):
        v = self.cls('x', 0.5 * np.arange(10), {'foo': 'bar'})
        w = v.copy(deep=deep)
        assert type(v) is type(w)
        assert_identical(v, w)
        assert v.dtype == w.dtype
        if self.cls is Variable:
            if deep:
                assert (source_ndarray(v.values) is not
                        source_ndarray(w.values))
            else:
                assert (source_ndarray(v.values) is
                        source_ndarray(w.values))
        assert_identical(v, copy(v))

    def test_copy_index(self):
        midx = pd.MultiIndex.from_product([['a', 'b'], [1, 2], [-1, -2]],
                                          names=('one', 'two', 'three'))
        v = self.cls('x', midx)
        for deep in [True, False]:
            w = v.copy(deep=deep)
            assert isinstance(w._data, PandasIndexAdapter)
            assert isinstance(w.to_index(), pd.MultiIndex)
            assert_array_equal(v._data.array, w._data.array)

    def test_copy_index_unicode_dtype(self):
        # regression test for GH: unicode indices were cast to object
        v = self.cls('x', np.array(['foo', 'bar'], dtype='<U3'))
        for deep in [True, False]:
            w = v.copy(deep=deep)
            assert w.dtype == v.dtype
            assert_identical(v, w)

    def test_copy_with_data(self):
        orig = Variable(('x', 'y'), [[1.5, 2.0], [3.1, 4.3]], {'foo': 'bar'})
        new_data = np.array([[2.5, 5.0], [7.1, 43]])
        actual = orig.copy(data=new_data)
        expected = orig.copy()
        expected.data = new_data
        assert_identical(expected, actual)

    def test_copy_with_data_errors(self):
        orig = Variable(('x', 'y'), [[1.5, 2.0], [3.1, 4.3]], {'foo': 'bar'})
        new_data = [2.5, 5.0]
        with raises_regex(ValueError, 'must match shape of object'):
            orig.copy(data=new_data)

    def test_copy_index_with_data(self):
        orig = IndexVariable('x', np.arange(5))
        new_data = np.arange(5, 10)
        actual = orig.copy(data=new_data)
        expected = orig.copy()
        expected.data = new_data
        assert_identical(expected, actual)

    def test_copy_index_with_data_errors(self):
        orig = IndexVariable('x', np.arange(5))
        new_data = np.arange(5, 20)
        with raises_regex(ValueError, 'must match shape of object'):
            orig.copy(data=new_data)

    def test_real_and_imag(self):
        v = self.cls('x', np.arange(3) - 1j * np.arange(3), {'foo': 'bar'})
        expected_re = self.cls('x', np.arange(3), {'foo': 'bar'})
        assert_identical(v.real, expected_re)

        expected_im = self.cls('x', -np.arange(3), {'foo': 'bar'})
        assert_identical(v.imag, expected_im)

        expected_abs = self.cls(
            'x', np.sqrt(2 * np.arange(3) ** 2)).to_base_variable()
        assert_allclose(abs(v), expected_abs)

    def test_aggregate_complex(self):
        # should skip NaNs
        v = self.cls('x', [1, 2j, np.nan])
        expected = Variable((), 0.5 + 1j)
        assert_allclose(v.mean(), expected)

    def test_pandas_cateogrical_dtype(self):
        data = pd.Categorical(np.arange(10, dtype='int64'))
        v = self.cls('x', data)
        print(v)  # should not error
        assert v.dtype == 'int64'

    def test_pandas_datetime64_with_tz(self):
        data = pd.date_range(start='2000-01-01',
                             tz=pytz.timezone('America/New_York'),
                             periods=10, freq='1h')
        v = self.cls('x', data)
        print(v)  # should not error
        if 'America/New_York' in str(data.dtype):
            # pandas is new enough that it has datetime64 with timezone dtype
            assert v.dtype == 'object'

    def test_multiindex(self):
        idx = pd.MultiIndex.from_product([list('abc'), [0, 1]])
        v = self.cls('x', idx)
        assert_identical(Variable((), ('a', 0)), v[0])
        assert_identical(v, v[:])

    def test_load(self):
        array = self.cls('x', np.arange(5))
        orig_data = array._data
        copied = array.copy(deep=True)
        if array.chunks is None:
            array.load()
            assert type(array._data) is type(orig_data)
            assert type(copied._data) is type(orig_data)
            assert_identical(array, copied)

    def test_getitem_advanced(self):
        v = self.cls(['x', 'y'], [[0, 1, 2], [3, 4, 5]])
        v_data = v.compute().data

        # orthogonal indexing
        v_new = v[([0, 1], [1, 0])]
        assert v_new.dims == ('x', 'y')
        assert_array_equal(v_new, v_data[[0, 1]][:, [1, 0]])

        v_new = v[[0, 1]]
        assert v_new.dims == ('x', 'y')
        assert_array_equal(v_new, v_data[[0, 1]])

        # with mixed arguments
        ind = Variable(['a'], [0, 1])
        v_new = v[dict(x=[0, 1], y=ind)]
        assert v_new.dims == ('x', 'a')
        assert_array_equal(v_new, v_data[[0, 1]][:, [0, 1]])

        # boolean indexing
        v_new = v[dict(x=[True, False], y=[False, True, False])]
        assert v_new.dims == ('x', 'y')
        assert_array_equal(v_new, v_data[0][1])

        # with scalar variable
        ind = Variable((), 2)
        v_new = v[dict(y=ind)]
        expected = v[dict(y=2)]
        assert_array_equal(v_new, expected)

        # with boolean variable with wrong shape
        ind = np.array([True, False])
        with raises_regex(IndexError, 'Boolean array size 2 is '):
            v[Variable(('a', 'b'), [[0, 1]]), ind]

        # boolean indexing with different dimension
        ind = Variable(['a'], [True, False, False])
        with raises_regex(IndexError, 'Boolean indexer should be'):
            v[dict(y=ind)]

    def test_getitem_uint_1d(self):
        # regression test for #1405
        v = self.cls(['x'], [0, 1, 2])
        v_data = v.compute().data

        v_new = v[np.array([0])]
        assert_array_equal(v_new, v_data[0])
        v_new = v[np.array([0], dtype="uint64")]
        assert_array_equal(v_new, v_data[0])

    def test_getitem_uint(self):
        # regression test for #1405
        v = self.cls(['x', 'y'], [[0, 1, 2], [3, 4, 5]])
        v_data = v.compute().data

        v_new = v[np.array([0])]
        assert_array_equal(v_new, v_data[[0], :])
        v_new = v[np.array([0], dtype="uint64")]
        assert_array_equal(v_new, v_data[[0], :])

        v_new = v[np.uint64(0)]
        assert_array_equal(v_new, v_data[0, :])

    def test_getitem_0d_array(self):
        # make sure 0d-np.array can be used as an indexer
        v = self.cls(['x'], [0, 1, 2])
        v_data = v.compute().data

        v_new = v[np.array([0])[0]]
        assert_array_equal(v_new, v_data[0])

        v_new = v[np.array(0)]
        assert_array_equal(v_new, v_data[0])

        v_new = v[Variable((), np.array(0))]
        assert_array_equal(v_new, v_data[0])

    def test_getitem_fancy(self):
        v = self.cls(['x', 'y'], [[0, 1, 2], [3, 4, 5]])
        v_data = v.compute().data

        ind = Variable(['a', 'b'], [[0, 1, 1], [1, 1, 0]])
        v_new = v[ind]
        assert v_new.dims == ('a', 'b', 'y')
        assert_array_equal(v_new, v_data[[[0, 1, 1], [1, 1, 0]], :])

        # It would be ok if indexed with the multi-dimensional array including
        # the same name
        ind = Variable(['x', 'b'], [[0, 1, 1], [1, 1, 0]])
        v_new = v[ind]
        assert v_new.dims == ('x', 'b', 'y')
        assert_array_equal(v_new, v_data[[[0, 1, 1], [1, 1, 0]], :])

        ind = Variable(['a', 'b'], [[0, 1, 2], [2, 1, 0]])
        v_new = v[dict(y=ind)]
        assert v_new.dims == ('x', 'a', 'b')
        assert_array_equal(v_new, v_data[:, ([0, 1, 2], [2, 1, 0])])

        ind = Variable(['a', 'b'], [[0, 0], [1, 1]])
        v_new = v[dict(x=[1, 0], y=ind)]
        assert v_new.dims == ('x', 'a', 'b')
        assert_array_equal(v_new, v_data[[1, 0]][:, ind])

        # along diagonal
        ind = Variable(['a'], [0, 1])
        v_new = v[ind, ind]
        assert v_new.dims == ('a',)
        assert_array_equal(v_new, v_data[[0, 1], [0, 1]])

        # with integer
        ind = Variable(['a', 'b'], [[0, 0], [1, 1]])
        v_new = v[dict(x=0, y=ind)]
        assert v_new.dims == ('a', 'b')
        assert_array_equal(v_new[0], v_data[0][[0, 0]])
        assert_array_equal(v_new[1], v_data[0][[1, 1]])

        # with slice
        ind = Variable(['a', 'b'], [[0, 0], [1, 1]])
        v_new = v[dict(x=slice(None), y=ind)]
        assert v_new.dims == ('x', 'a', 'b')
        assert_array_equal(v_new, v_data[:, [[0, 0], [1, 1]]])

        ind = Variable(['a', 'b'], [[0, 0], [1, 1]])
        v_new = v[dict(x=ind, y=slice(None))]
        assert v_new.dims == ('a', 'b', 'y')
        assert_array_equal(v_new, v_data[[[0, 0], [1, 1]], :])

        ind = Variable(['a', 'b'], [[0, 0], [1, 1]])
        v_new = v[dict(x=ind, y=slice(None, 1))]
        assert v_new.dims == ('a', 'b', 'y')
        assert_array_equal(v_new, v_data[[[0, 0], [1, 1]], slice(None, 1)])

        # slice matches explicit dimension
        ind = Variable(['y'], [0, 1])
        v_new = v[ind, :2]
        assert v_new.dims == ('y',)
        assert_array_equal(v_new, v_data[[0, 1], [0, 1]])

        # with multiple slices
        v = self.cls(['x', 'y', 'z'], [[[1, 2, 3], [4, 5, 6]]])
        ind = Variable(['a', 'b'], [[0]])
        v_new = v[ind, :, :]
        expected = Variable(['a', 'b', 'y', 'z'], v.data[np.newaxis, ...])
        assert_identical(v_new, expected)

        v = Variable(['w', 'x', 'y', 'z'], [[[[1, 2, 3], [4, 5, 6]]]])
        ind = Variable(['y'], [0])
        v_new = v[ind, :, 1:2, 2]
        expected = Variable(['y', 'x'], [[6]])
        assert_identical(v_new, expected)

        # slice and vector mixed indexing resulting in the same dimension
        v = Variable(['x', 'y', 'z'], np.arange(60).reshape(3, 4, 5))
        ind = Variable(['x'], [0, 1, 2])
        v_new = v[:, ind]
        expected = Variable(('x', 'z'), np.zeros((3, 5)))
        expected[0] = v.data[0, 0]
        expected[1] = v.data[1, 1]
        expected[2] = v.data[2, 2]
        assert_identical(v_new, expected)

        v_new = v[:, ind.data]
        assert v_new.shape == (3, 3, 5)

    def test_getitem_error(self):
        v = self.cls(['x', 'y'], [[0, 1, 2], [3, 4, 5]])

        with raises_regex(IndexError, "labeled multi-"):
            v[[[0, 1], [1, 2]]]

        ind_x = Variable(['a'], [0, 1, 1])
        ind_y = Variable(['a'], [0, 1])
        with raises_regex(IndexError, "Dimensions of indexers "):
            v[ind_x, ind_y]

        ind = Variable(['a', 'b'], [[True, False], [False, True]])
        with raises_regex(IndexError, '2-dimensional boolean'):
            v[dict(x=ind)]

        v = Variable(['x', 'y', 'z'], np.arange(60).reshape(3, 4, 5))
        ind = Variable(['x'], [0, 1])
        with raises_regex(IndexError, 'Dimensions of indexers mis'):
            v[:, ind]

    def test_pad(self):
        data = np.arange(4 * 3 * 2).reshape(4, 3, 2)
        v = self.cls(['x', 'y', 'z'], data)

        xr_args = [{'x': (2, 1)}, {'y': (0, 3)}, {'x': (3, 1), 'z': (2, 0)}]
        np_args = [((2, 1), (0, 0), (0, 0)), ((0, 0), (0, 3), (0, 0)),
                   ((3, 1), (0, 0), (2, 0))]
        for xr_arg, np_arg in zip(xr_args, np_args):
            actual = v.pad_with_fill_value(**xr_arg)
            expected = np.pad(np.array(v.data.astype(float)), np_arg,
                              mode='constant', constant_values=np.nan)
            assert_array_equal(actual, expected)
            assert isinstance(actual._data, type(v._data))

        # for the boolean array, we pad False
        data = np.full_like(data, False, dtype=bool).reshape(4, 3, 2)
        v = self.cls(['x', 'y', 'z'], data)
        for xr_arg, np_arg in zip(xr_args, np_args):
            actual = v.pad_with_fill_value(fill_value=False, **xr_arg)
            expected = np.pad(np.array(v.data), np_arg,
                              mode='constant', constant_values=False)
            assert_array_equal(actual, expected)

    def test_rolling_window(self):
        # Just a working test. See test_nputils for the algorithm validation
        v = self.cls(['x', 'y', 'z'],
                     np.arange(40 * 30 * 2).reshape(40, 30, 2))
        for (d, w) in [('x', 3), ('y', 5)]:
            v_rolling = v.rolling_window(d, w, d + '_window')
            assert v_rolling.dims == ('x', 'y', 'z', d + '_window')
            assert v_rolling.shape == v.shape + (w, )

            v_rolling = v.rolling_window(d, w, d + '_window', center=True)
            assert v_rolling.dims == ('x', 'y', 'z', d + '_window')
            assert v_rolling.shape == v.shape + (w, )

            # dask and numpy result should be the same
            v_loaded = v.load().rolling_window(d, w, d + '_window',
                                               center=True)
            assert_array_equal(v_rolling, v_loaded)

            # numpy backend should not be over-written
            if isinstance(v._data, np.ndarray):
                with pytest.raises(ValueError):
                    v_loaded[0] = 1.0


class TestVariable(VariableSubclassobjects):
    cls = staticmethod(Variable)

    @pytest.fixture(autouse=True)
    def setup(self):
        self.d = np.random.random((10, 3)).astype(np.float64)

    def test_data_and_values(self):
        v = Variable(['time', 'x'], self.d)
        assert_array_equal(v.data, self.d)
        assert_array_equal(v.values, self.d)
        assert source_ndarray(v.values) is self.d
        with pytest.raises(ValueError):
            # wrong size
            v.values = np.random.random(5)
        d2 = np.random.random((10, 3))
        v.values = d2
        assert source_ndarray(v.values) is d2
        d3 = np.random.random((10, 3))
        v.data = d3
        assert source_ndarray(v.data) is d3

    def test_numpy_same_methods(self):
        v = Variable([], np.float32(0.0))
        assert v.item() == 0
        assert type(v.item()) is float

        v = IndexVariable('x', np.arange(5))
        assert 2 == v.searchsorted(2)

    def test_datetime64_conversion_scalar(self):
        expected = np.datetime64('2000-01-01', 'ns')
        for values in [
            np.datetime64('2000-01-01'),
            pd.Timestamp('2000-01-01T00'),
            datetime(2000, 1, 1),
        ]:
            v = Variable([], values)
            assert v.dtype == np.dtype('datetime64[ns]')
            assert v.values == expected
            assert v.values.dtype == np.dtype('datetime64[ns]')

    def test_timedelta64_conversion_scalar(self):
        expected = np.timedelta64(24 * 60 * 60 * 10 ** 9, 'ns')
        for values in [
            np.timedelta64(1, 'D'),
            pd.Timedelta('1 day'),
            timedelta(days=1),
        ]:
            v = Variable([], values)
            assert v.dtype == np.dtype('timedelta64[ns]')
            assert v.values == expected
            assert v.values.dtype == np.dtype('timedelta64[ns]')

    def test_0d_str(self):
        v = Variable([], 'foo')
        assert v.dtype == np.dtype('U3')
        assert v.values == 'foo'

        v = Variable([], np.string_('foo'))
        assert v.dtype == np.dtype('S3')
        assert v.values == bytes('foo', 'ascii')

    def test_0d_datetime(self):
        v = Variable([], pd.Timestamp('2000-01-01'))
        assert v.dtype == np.dtype('datetime64[ns]')
        assert v.values == np.datetime64('2000-01-01', 'ns')

    def test_0d_timedelta(self):
        for td in [pd.to_timedelta('1s'), np.timedelta64(1, 's')]:
            v = Variable([], td)
            assert v.dtype == np.dtype('timedelta64[ns]')
            assert v.values == np.timedelta64(10 ** 9, 'ns')

    def test_equals_and_identical(self):
        d = np.random.rand(10, 3)
        d[0, 0] = np.nan
        v1 = Variable(('dim1', 'dim2'), data=d,
                      attrs={'att1': 3, 'att2': [1, 2, 3]})
        v2 = Variable(('dim1', 'dim2'), data=d,
                      attrs={'att1': 3, 'att2': [1, 2, 3]})
        assert v1.equals(v2)
        assert v1.identical(v2)

        v3 = Variable(('dim1', 'dim3'), data=d)
        assert not v1.equals(v3)

        v4 = Variable(('dim1', 'dim2'), data=d)
        assert v1.equals(v4)
        assert not v1.identical(v4)

        v5 = deepcopy(v1)
        v5.values[:] = np.random.rand(10, 3)
        assert not v1.equals(v5)

        assert not v1.equals(None)
        assert not v1.equals(d)

        assert not v1.identical(None)
        assert not v1.identical(d)

    def test_broadcast_equals(self):
        v1 = Variable((), np.nan)
        v2 = Variable(('x'), [np.nan, np.nan])
        assert v1.broadcast_equals(v2)
        assert not v1.equals(v2)
        assert not v1.identical(v2)

        v3 = Variable(('x'), [np.nan])
        assert v1.broadcast_equals(v3)
        assert not v1.equals(v3)
        assert not v1.identical(v3)

        assert not v1.broadcast_equals(None)

        v4 = Variable(('x'), [np.nan] * 3)
        assert not v2.broadcast_equals(v4)

    def test_no_conflicts(self):
        v1 = Variable(('x'), [1, 2, np.nan, np.nan])
        v2 = Variable(('x'), [np.nan, 2, 3, np.nan])
        assert v1.no_conflicts(v2)
        assert not v1.equals(v2)
        assert not v1.broadcast_equals(v2)
        assert not v1.identical(v2)

        assert not v1.no_conflicts(None)

        v3 = Variable(('y'), [np.nan, 2, 3, np.nan])
        assert not v3.no_conflicts(v1)

        d = np.array([1, 2, np.nan, np.nan])
        assert not v1.no_conflicts(d)
        assert not v2.no_conflicts(d)

        v4 = Variable(('w', 'x'), [d])
        assert v1.no_conflicts(v4)

    def test_as_variable(self):
        data = np.arange(10)
        expected = Variable('x', data)
        expected_extra = Variable('x', data, attrs={'myattr': 'val'},
                                  encoding={'scale_factor': 1})

        assert_identical(expected, as_variable(expected))

        ds = Dataset({'x': expected})
        var = as_variable(ds['x']).to_base_variable()
        assert_identical(expected, var)
        assert not isinstance(ds['x'], Variable)
        assert isinstance(as_variable(ds['x']), Variable)

        xarray_tuple = (expected_extra.dims, expected_extra.values,
                        expected_extra.attrs, expected_extra.encoding)
        assert_identical(expected_extra, as_variable(xarray_tuple))

        with raises_regex(TypeError, 'tuple of form'):
            as_variable(tuple(data))
        with raises_regex(ValueError, 'tuple of form'):  # GH1016
            as_variable(('five', 'six', 'seven'))
        with raises_regex(
                TypeError, 'without an explicit list of dimensions'):
            as_variable(data)

        actual = as_variable(data, name='x')
        assert_identical(expected.to_index_variable(), actual)

        actual = as_variable(0)
        expected = Variable([], 0)
        assert_identical(expected, actual)

        data = np.arange(9).reshape((3, 3))
        expected = Variable(('x', 'y'), data)
        with raises_regex(
                ValueError, 'without explicit dimension names'):
            as_variable(data, name='x')
        with raises_regex(
                ValueError, 'has more than 1-dimension'):
            as_variable(expected, name='x')

        # test datetime, timedelta conversion
        dt = np.array([datetime(1999, 1, 1) + timedelta(days=x)
                       for x in range(10)])
        assert as_variable(dt, 'time').dtype.kind == 'M'
        td = np.array([timedelta(days=x) for x in range(10)])
        assert as_variable(td, 'time').dtype.kind == 'm'

    def test_repr(self):
        v = Variable(['time', 'x'], [[1, 2, 3], [4, 5, 6]], {'foo': 'bar'})
        expected = dedent("""
        <xarray.Variable (time: 2, x: 3)>
        array([[1, 2, 3],
               [4, 5, 6]])
        Attributes:
            foo:      bar
        """).strip()
        assert expected == repr(v)

    def test_repr_lazy_data(self):
        v = Variable('x', LazilyOuterIndexedArray(np.arange(2e5)))
        assert '200000 values with dtype' in repr(v)
        assert isinstance(v._data, LazilyOuterIndexedArray)

    def test_detect_indexer_type(self):
        """ Tests indexer type was correctly detected. """
        data = np.random.random((10, 11))
        v = Variable(['x', 'y'], data)

        _, ind, _ = v._broadcast_indexes((0, 1))
        assert type(ind) == indexing.BasicIndexer

        _, ind, _ = v._broadcast_indexes((0, slice(0, 8, 2)))
        assert type(ind) == indexing.BasicIndexer

        _, ind, _ = v._broadcast_indexes((0, [0, 1]))
        assert type(ind) == indexing.OuterIndexer

        _, ind, _ = v._broadcast_indexes(([0, 1], 1))
        assert type(ind) == indexing.OuterIndexer

        _, ind, _ = v._broadcast_indexes(([0, 1], [1, 2]))
        assert type(ind) == indexing.OuterIndexer

        _, ind, _ = v._broadcast_
```


# xarray/tests/test_dataarray.py

```
import pickle
import sys
import warnings
from collections import OrderedDict
from copy import deepcopy
from textwrap import dedent

import numpy as np
import pandas as pd
import pytest

import xarray as xr
from xarray import (
    DataArray, Dataset, IndexVariable, Variable, align, broadcast)
from xarray.coding.times import CFDatetimeCoder
from xarray.convert import from_cdms2
from xarray.core import dtypes
from xarray.core.common import ALL_DIMS, full_like
from xarray.tests import (
    LooseVersion, ReturnItem, assert_allclose, assert_array_equal,
    assert_equal, assert_identical, raises_regex, requires_bottleneck,
    requires_cftime, requires_dask, requires_iris, requires_np113,
    requires_numbagg, requires_scipy, source_ndarray)


class TestDataArray:
    @pytest.fixture(autouse=True)
    def setup(self):
        self.attrs = {'attr1': 'value1', 'attr2': 2929}
        self.x = np.random.random((10, 20))
        self.v = Variable(['x', 'y'], self.x)
        self.va = Variable(['x', 'y'], self.x, self.attrs)
        self.ds = Dataset({'foo': self.v})
        self.dv = self.ds['foo']

        self.mindex = pd.MultiIndex.from_product([['a', 'b'], [1, 2]],
                                                 names=('level_1', 'level_2'))
        self.mda = DataArray([0, 1, 2, 3], coords={'x': self.mindex}, dims='x')

    def test_repr(self):
        v = Variable(['time', 'x'], [[1, 2, 3], [4, 5, 6]], {'foo': 'bar'})
        coords = OrderedDict([('x', np.arange(3, dtype=np.int64)),
                              ('other', np.int64(0))])
        data_array = DataArray(v, coords, name='my_variable')
        expected = dedent("""\
        <xarray.DataArray 'my_variable' (time: 2, x: 3)>
        array([[1, 2, 3],
               [4, 5, 6]])
        Coordinates:
          * x        (x) int64 0 1 2
            other    int64 0
        Dimensions without coordinates: time
        Attributes:
            foo:      bar""")
        assert expected == repr(data_array)

    def test_repr_multiindex(self):
        expected = dedent("""\
        <xarray.DataArray (x: 4)>
        array([0, 1, 2, 3])
        Coordinates:
          * x        (x) MultiIndex
          - level_1  (x) object 'a' 'a' 'b' 'b'
          - level_2  (x) int64 1 2 1 2""")
        assert expected == repr(self.mda)

    def test_repr_multiindex_long(self):
        mindex_long = pd.MultiIndex.from_product(
            [['a', 'b', 'c', 'd'], [1, 2, 3, 4, 5, 6, 7, 8]],
            names=('level_1', 'level_2'))
        mda_long = DataArray(list(range(32)),
                             coords={'x': mindex_long}, dims='x')
        expected = dedent("""\
        <xarray.DataArray (x: 32)>
        array([ 0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16, 17,
               18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31])
        Coordinates:
          * x        (x) MultiIndex
          - level_1  (x) object 'a' 'a' 'a' 'a' 'a' 'a' 'a' ... 'd' 'd' 'd' 'd' 'd' 'd'
          - level_2  (x) int64 1 2 3 4 5 6 7 8 1 2 3 4 5 6 ... 4 5 6 7 8 1 2 3 4 5 6 7 8""")  # noqa: E501
        assert expected == repr(mda_long)

    def test_properties(self):
        assert_equal(self.dv.variable, self.v)
        assert_array_equal(self.dv.values, self.v.values)
        for attr in ['dims', 'dtype', 'shape', 'size', 'nbytes',
                     'ndim', 'attrs']:
            assert getattr(self.dv, attr) == getattr(self.v, attr)
        assert len(self.dv) == len(self.v)
        assert_equal(self.dv.variable, self.v)
        assert set(self.dv.coords) == set(self.ds.coords)
        for k, v in self.dv.coords.items():
            assert_array_equal(v, self.ds.coords[k])
        with pytest.raises(AttributeError):
            self.dv.dataset
        assert isinstance(self.ds['x'].to_index(), pd.Index)
        with raises_regex(ValueError, 'must be 1-dimensional'):
            self.ds['foo'].to_index()
        with pytest.raises(AttributeError):
            self.dv.variable = self.v

    def test_data_property(self):
        array = DataArray(np.zeros((3, 4)))
        actual = array.copy()
        actual.values = np.ones((3, 4))
        assert_array_equal(np.ones((3, 4)), actual.values)
        actual.data = 2 * np.ones((3, 4))
        assert_array_equal(2 * np.ones((3, 4)), actual.data)
        assert_array_equal(actual.data, actual.values)

    def test_indexes(self):
        array = DataArray(np.zeros((2, 3)),
                          [('x', [0, 1]), ('y', ['a', 'b', 'c'])])
        expected = OrderedDict([('x', pd.Index([0, 1])),
                                ('y', pd.Index(['a', 'b', 'c']))])
        assert array.indexes.keys() == expected.keys()
        for k in expected:
            assert array.indexes[k].equals(expected[k])

    def test_get_index(self):
        array = DataArray(np.zeros((2, 3)), coords={'x': ['a', 'b']},
                          dims=['x', 'y'])
        assert array.get_index('x').equals(pd.Index(['a', 'b']))
        assert array.get_index('y').equals(pd.Index([0, 1, 2]))
        with pytest.raises(KeyError):
            array.get_index('z')

    def test_get_index_size_zero(self):
        array = DataArray(np.zeros((0,)), dims=['x'])
        actual = array.get_index('x')
        expected = pd.Index([], dtype=np.int64)
        assert actual.equals(expected)
        assert actual.dtype == expected.dtype

    def test_struct_array_dims(self):
        """
        This test checks subraction of two DataArrays for the case
        when dimension is a structured array.
        """
        # GH837, GH861
        # checking array subraction when dims are the same
        # note: names need to be in sorted order to align consistently with
        # pandas < 0.24 and >= 0.24.
        p_data = np.array([('Abe', 180), ('Stacy', 150), ('Dick', 200)],
                          dtype=[('name', '|S256'), ('height', object)])
        weights_0 = DataArray([80, 56, 120], dims=['participant'],
                              coords={'participant': p_data})
        weights_1 = DataArray([81, 52, 115], dims=['participant'],
                              coords={'participant': p_data})
        actual = weights_1 - weights_0

        expected = DataArray([1, -4, -5], dims=['participant'],
                             coords={'participant': p_data})

        assert_identical(actual, expected)

        # checking array subraction when dims are not the same
        p_data_alt = np.array([('Abe', 180), ('Stacy', 151), ('Dick', 200)],
                              dtype=[('name', '|S256'), ('height', object)])
        weights_1 = DataArray([81, 52, 115], dims=['participant'],
                              coords={'participant': p_data_alt})
        actual = weights_1 - weights_0

        expected = DataArray([1, -5], dims=['participant'],
                             coords={'participant': p_data[[0, 2]]})

        assert_identical(actual, expected)

        # checking array subraction when dims are not the same and one
        # is np.nan
        p_data_nan = np.array([('Abe', 180), ('Stacy', np.nan), ('Dick', 200)],
                              dtype=[('name', '|S256'), ('height', object)])
        weights_1 = DataArray([81, 52, 115], dims=['participant'],
                              coords={'participant': p_data_nan})
        actual = weights_1 - weights_0

        expected = DataArray([1, -5], dims=['participant'],
                             coords={'participant': p_data[[0, 2]]})

        assert_identical(actual, expected)

    def test_name(self):
        arr = self.dv
        assert arr.name == 'foo'

        copied = arr.copy()
        arr.name = 'bar'
        assert arr.name == 'bar'
        assert_equal(copied, arr)

        actual = DataArray(IndexVariable('x', [3]))
        actual.name = 'y'
        expected = DataArray([3], [('x', [3])], name='y')
        assert_identical(actual, expected)

    def test_dims(self):
        arr = self.dv
        assert arr.dims == ('x', 'y')

        with raises_regex(AttributeError, 'you cannot assign'):
            arr.dims = ('w', 'z')

    def test_sizes(self):
        array = DataArray(np.zeros((3, 4)), dims=['x', 'y'])
        assert array.sizes == {'x': 3, 'y': 4}
        assert tuple(array.sizes) == array.dims
        with pytest.raises(TypeError):
            array.sizes['foo'] = 5

    def test_encoding(self):
        expected = {'foo': 'bar'}
        self.dv.encoding['foo'] = 'bar'
        assert expected == self.dv.encoding

        expected = {'baz': 0}
        self.dv.encoding = expected

        assert expected is not self.dv.encoding

    def test_constructor(self):
        data = np.random.random((2, 3))

        actual = DataArray(data)
        expected = Dataset({None: (['dim_0', 'dim_1'], data)})[None]
        assert_identical(expected, actual)

        actual = DataArray(data, [['a', 'b'], [-1, -2, -3]])
        expected = Dataset({None: (['dim_0', 'dim_1'], data),
                            'dim_0': ('dim_0', ['a', 'b']),
                            'dim_1': ('dim_1', [-1, -2, -3])})[None]
        assert_identical(expected, actual)

        actual = DataArray(data, [pd.Index(['a', 'b'], name='x'),
                                  pd.Index([-1, -2, -3], name='y')])
        expected = Dataset({None: (['x', 'y'], data),
                            'x': ('x', ['a', 'b']),
                            'y': ('y', [-1, -2, -3])})[None]
        assert_identical(expected, actual)

        coords = [['a', 'b'], [-1, -2, -3]]
        actual = DataArray(data, coords, ['x', 'y'])
        assert_identical(expected, actual)

        coords = [pd.Index(['a', 'b'], name='A'),
                  pd.Index([-1, -2, -3], name='B')]
        actual = DataArray(data, coords, ['x', 'y'])
        assert_identical(expected, actual)

        coords = {'x': ['a', 'b'], 'y': [-1, -2, -3]}
        actual = DataArray(data, coords, ['x', 'y'])
        assert_identical(expected, actual)

        coords = [('x', ['a', 'b']), ('y', [-1, -2, -3])]
        actual = DataArray(data, coords)
        assert_identical(expected, actual)

        expected = Dataset({None: (['x', 'y'], data),
                            'x': ('x', ['a', 'b'])})[None]
        actual = DataArray(data, {'x': ['a', 'b']}, ['x', 'y'])
        assert_identical(expected, actual)

        actual = DataArray(data, dims=['x', 'y'])
        expected = Dataset({None: (['x', 'y'], data)})[None]
        assert_identical(expected, actual)

        actual = DataArray(data, dims=['x', 'y'], name='foo')
        expected = Dataset({'foo': (['x', 'y'], data)})['foo']
        assert_identical(expected, actual)

        actual = DataArray(data, name='foo')
        expected = Dataset({'foo': (['dim_0', 'dim_1'], data)})['foo']
        assert_identical(expected, actual)

        actual = DataArray(data, dims=['x', 'y'], attrs={'bar': 2})
        expected = Dataset({None: (['x', 'y'], data, {'bar': 2})})[None]
        assert_identical(expected, actual)

        actual = DataArray(data, dims=['x', 'y'])
        expected = Dataset({None: (['x', 'y'], data, {}, {'bar': 2})})[None]
        assert_identical(expected, actual)

    def test_constructor_invalid(self):
        data = np.random.randn(3, 2)

        with raises_regex(ValueError, 'coords is not dict-like'):
            DataArray(data, [[0, 1, 2]], ['x', 'y'])

        with raises_regex(ValueError, 'not a subset of the .* dim'):
            DataArray(data, {'x': [0, 1, 2]}, ['a', 'b'])
        with raises_regex(ValueError, 'not a subset of the .* dim'):
            DataArray(data, {'x': [0, 1, 2]})

        with raises_regex(TypeError, 'is not a string'):
            DataArray(data, dims=['x', None])

        with raises_regex(ValueError, 'conflicting sizes for dim'):
            DataArray([1, 2, 3], coords=[('x', [0, 1])])
        with raises_regex(ValueError, 'conflicting sizes for dim'):
            DataArray([1, 2], coords={'x': [0, 1], 'y': ('x', [1])}, dims='x')

        with raises_regex(ValueError, 'conflicting MultiIndex'):
            DataArray(np.random.rand(4, 4),
                      [('x', self.mindex), ('y', self.mindex)])
        with raises_regex(ValueError, 'conflicting MultiIndex'):
            DataArray(np.random.rand(4, 4),
                      [('x', self.mindex), ('level_1', range(4))])

        with raises_regex(ValueError, 'matching the dimension size'):
            DataArray(data, coords={'x': 0}, dims=['x', 'y'])

    def test_constructor_from_self_described(self):
        data = [[-0.1, 21], [0, 2]]
        expected = DataArray(data,
                             coords={'x': ['a', 'b'], 'y': [-1, -2]},
                             dims=['x', 'y'], name='foobar',
                             attrs={'bar': 2})
        actual = DataArray(expected)
        assert_identical(expected, actual)

        actual = DataArray(expected.values, actual.coords)
        assert_equal(expected, actual)

        frame = pd.DataFrame(data, index=pd.Index(['a', 'b'], name='x'),
                             columns=pd.Index([-1, -2], name='y'))
        actual = DataArray(frame)
        assert_equal(expected, actual)

        series = pd.Series(data[0], index=pd.Index([-1, -2], name='y'))
        actual = DataArray(series)
        assert_equal(expected[0].reset_coords('x', drop=True), actual)

        if LooseVersion(pd.__version__) < '0.25.0':
            with warnings.catch_warnings():
                warnings.filterwarnings('ignore', r'\W*Panel is deprecated')
                panel = pd.Panel({0: frame})
            actual = DataArray(panel)
            expected = DataArray([data], expected.coords, ['dim_0', 'x', 'y'])
            expected['dim_0'] = [0]
            assert_identical(expected, actual)

        expected = DataArray(data,
                             coords={'x': ['a', 'b'], 'y': [-1, -2],
                                     'a': 0, 'z': ('x', [-0.5, 0.5])},
                             dims=['x', 'y'])
        actual = DataArray(expected)
        assert_identical(expected, actual)

        actual = DataArray(expected.values, expected.coords)
        assert_identical(expected, actual)

        expected = Dataset({'foo': ('foo', ['a', 'b'])})['foo']
        actual = DataArray(pd.Index(['a', 'b'], name='foo'))
        assert_identical(expected, actual)

        actual = DataArray(IndexVariable('foo', ['a', 'b']))
        assert_identical(expected, actual)

    def test_constructor_from_0d(self):
        expected = Dataset({None: ([], 0)})[None]
        actual = DataArray(0)
        assert_identical(expected, actual)

    @requires_dask
    def test_constructor_dask_coords(self):
        # regression test for GH1684
        import dask.array as da

        coord = da.arange(8, chunks=(4,))
        data = da.random.random((8, 8), chunks=(4, 4)) + 1
        actual = DataArray(data, coords={'x': coord, 'y': coord},
                           dims=['x', 'y'])

        ecoord = np.arange(8)
        expected = DataArray(data, coords={'x': ecoord, 'y': ecoord},
                             dims=['x', 'y'])
        assert_equal(actual, expected)

    def test_equals_and_identical(self):
        orig = DataArray(np.arange(5.0), {'a': 42}, dims='x')

        expected = orig
        actual = orig.copy()
        assert expected.equals(actual)
        assert expected.identical(actual)

        actual = expected.rename('baz')
        assert expected.equals(actual)
        assert not expected.identical(actual)

        actual = expected.rename({'x': 'xxx'})
        assert not expected.equals(actual)
        assert not expected.identical(actual)

        actual = expected.copy()
        actual.attrs['foo'] = 'bar'
        assert expected.equals(actual)
        assert not expected.identical(actual)

        actual = expected.copy()
        actual['x'] = ('x', -np.arange(5))
        assert not expected.equals(actual)
        assert not expected.identical(actual)

        actual = expected.reset_coords(drop=True)
        assert not expected.equals(actual)
        assert not expected.identical(actual)

        actual = orig.copy()
        actual[0] = np.nan
        expected = actual.copy()
        assert expected.equals(actual)
        assert expected.identical(actual)

        actual[:] = np.nan
        assert not expected.equals(actual)
        assert not expected.identical(actual)

        actual = expected.copy()
        actual['a'] = 100000
        assert not expected.equals(actual)
        assert not expected.identical(actual)

    def test_equals_failures(self):
        orig = DataArray(np.arange(5.0), {'a': 42}, dims='x')
        assert not orig.equals(np.arange(5))
        assert not orig.identical(123)
        assert not orig.broadcast_equals({1: 2})

    def test_broadcast_equals(self):
        a = DataArray([0, 0], {'y': 0}, dims='x')
        b = DataArray([0, 0], {'y': ('x', [0, 0])}, dims='x')
        assert a.broadcast_equals(b)
        assert b.broadcast_equals(a)
        assert not a.equals(b)
        assert not a.identical(b)

        c = DataArray([0], coords={'x': 0}, dims='y')
        assert not a.broadcast_equals(c)
        assert not c.broadcast_equals(a)

    def test_getitem(self):
        # strings pull out dataarrays
        assert_identical(self.dv, self.ds['foo'])
        x = self.dv['x']
        y = self.dv['y']
        assert_identical(self.ds['x'], x)
        assert_identical(self.ds['y'], y)

        I = ReturnItem()  # noqa
        for i in [I[:], I[...], I[x.values], I[x.variable], I[x], I[x, y],
                  I[x.values > -1], I[x.variable > -1], I[x > -1],
                  I[x > -1, y > -1]]:
            assert_equal(self.dv, self.dv[i])
        for i in [I[0], I[:, 0], I[:3, :2],
                  I[x.values[:3]], I[x.variable[:3]],
                  I[x[:3]], I[x[:3], y[:4]],
                  I[x.values > 3], I[x.variable > 3],
                  I[x > 3], I[x > 3, y > 3]]:
            assert_array_equal(self.v[i], self.dv[i])

    def test_getitem_dict(self):
        actual = self.dv[{'x': slice(3), 'y': 0}]
        expected = self.dv.isel(x=slice(3), y=0)
        assert_identical(expected, actual)

    def test_getitem_coords(self):
        orig = DataArray([[10], [20]],
                         {'x': [1, 2], 'y': [3], 'z': 4,
                          'x2': ('x', ['a', 'b']),
                          'y2': ('y', ['c']),
                          'xy': (['y', 'x'], [['d', 'e']])},
                         dims=['x', 'y'])

        assert_identical(orig, orig[:])
        assert_identical(orig, orig[:, :])
        assert_identical(orig, orig[...])
        assert_identical(orig, orig[:2, :1])
        assert_identical(orig, orig[[0, 1], [0]])

        actual = orig[0, 0]
        expected = DataArray(
            10, {'x': 1, 'y': 3, 'z': 4, 'x2': 'a', 'y2': 'c', 'xy': 'd'})
        assert_identical(expected, actual)

        actual = orig[0, :]
        expected = DataArray(
            [10], {'x': 1, 'y': [3], 'z': 4, 'x2': 'a', 'y2': ('y', ['c']),
                   'xy': ('y', ['d'])},
            dims='y')
        assert_identical(expected, actual)

        actual = orig[:, 0]
        expected = DataArray(
            [10, 20], {'x': [1, 2], 'y': 3, 'z': 4, 'x2': ('x', ['a', 'b']),
                       'y2': 'c', 'xy': ('x', ['d', 'e'])},
            dims='x')
        assert_identical(expected, actual)

    def test_getitem_dataarray(self):
        # It should not conflict
        da = DataArray(np.arange(12).reshape((3, 4)), dims=['x', 'y'])
        ind = DataArray([[0, 1], [0, 1]], dims=['x', 'z'])
        actual = da[ind]
        assert_array_equal(actual, da.values[[[0, 1], [0, 1]], :])

        da = DataArray(np.arange(12).reshape((3, 4)), dims=['x', 'y'],
                       coords={'x': [0, 1, 2], 'y': ['a', 'b', 'c', 'd']})
        ind = xr.DataArray([[0, 1], [0, 1]], dims=['X', 'Y'])
        actual = da[ind]
        expected = da.values[[[0, 1], [0, 1]], :]
        assert_array_equal(actual, expected)
        assert actual.dims == ('X', 'Y', 'y')

        # boolean indexing
        ind = xr.DataArray([True, True, False], dims=['x'])
        assert_equal(da[ind], da[[0, 1], :])
        assert_equal(da[ind], da[[0, 1]])
        assert_equal(da[ind], da[ind.values])

    def test_getitem_empty_index(self):
        da = DataArray(np.arange(12).reshape((3, 4)), dims=['x', 'y'])
        assert_identical(da[{'x': []}],
                         DataArray(np.zeros((0, 4)), dims=['x', 'y']))
        assert_identical(da.loc[{'y': []}],
                         DataArray(np.zeros((3, 0)), dims=['x', 'y']))
        assert_identical(da[[]], DataArray(np.zeros((0, 4)), dims=['x', 'y']))

    def test_setitem(self):
        # basic indexing should work as numpy's indexing
        tuples = [(0, 0), (0, slice(None, None)),
                  (slice(None, None), slice(None, None)),
                  (slice(None, None), 0),
                  ([1, 0], slice(None, None)),
                  (slice(None, None), [1, 0])]
        for t in tuples:
            expected = np.arange(6).reshape(3, 2)
            orig = DataArray(np.arange(6).reshape(3, 2),
                             {'x': [1, 2, 3], 'y': ['a', 'b'], 'z': 4,
                              'x2': ('x', ['a', 'b', 'c']),
                              'y2': ('y', ['d', 'e'])},
                             dims=['x', 'y'])
            orig[t] = 1
            expected[t] = 1
            assert_array_equal(orig.values, expected)

    def test_setitem_fancy(self):
        # vectorized indexing
        da = DataArray(np.ones((3, 2)), dims=['x', 'y'])
        ind = Variable(['a'], [0, 1])
        da[dict(x=ind, y=ind)] = 0
        expected = DataArray([[0, 1], [1, 0], [1, 1]], dims=['x', 'y'])
        assert_identical(expected, da)
        # assign another 0d-variable
        da[dict(x=ind, y=ind)] = Variable((), 0)
        expected = DataArray([[0, 1], [1, 0], [1, 1]], dims=['x', 'y'])
        assert_identical(expected, da)
        # assign another 1d-variable
        da[dict(x=ind, y=ind)] = Variable(['a'], [2, 3])
        expected = DataArray([[2, 1], [1, 3], [1, 1]], dims=['x', 'y'])
        assert_identical(expected, da)

        # 2d-vectorized indexing
        da = DataArray(np.ones((3, 2)), dims=['x', 'y'])
        ind_x = DataArray([[0, 1]], dims=['a', 'b'])
        ind_y = DataArray([[1, 0]], dims=['a', 'b'])
        da[dict(x=ind_x, y=ind_y)] = 0
        expected = DataArray([[1, 0], [0, 1], [1, 1]], dims=['x', 'y'])
        assert_identical(expected, da)

        da = DataArray(np.ones((3, 2)), dims=['x', 'y'])
        ind = Variable(['a'], [0, 1])
        da[ind] = 0
        expected = DataArray([[0, 0], [0, 0], [1, 1]], dims=['x', 'y'])
        assert_identical(expected, da)

    def test_setitem_dataarray(self):
        def get_data():
            return DataArray(np.ones((4, 3, 2)), dims=['x', 'y', 'z'],
                             coords={'x': np.arange(4), 'y': ['a', 'b', 'c'],
                                     'non-dim': ('x', [1, 3, 4, 2])})

        da = get_data()
        # indexer with inconsistent coordinates.
        ind = DataArray(np.arange(1, 4), dims=['x'],
                        coords={'x': np.random.randn(3)})
        with raises_regex(IndexError, "dimension coordinate 'x'"):
            da[dict(x=ind)] = 0

        # indexer with consistent coordinates.
        ind = DataArray(np.arange(1, 4), dims=['x'],
                        coords={'x': np.arange(1, 4)})
        da[dict(x=ind)] = 0  # should not raise
        assert np.allclose(da[dict(x=ind)].values, 0)
        assert_identical(da['x'], get_data()['x'])
        assert_identical(da['non-dim'], get_data()['non-dim'])

        da = get_data()
        # conflict in the assigning values
        value = xr.DataArray(np.zeros((3, 3, 2)), dims=['x', 'y', 'z'],
                             coords={'x': [0, 1, 2],
                                     'non-dim': ('x', [0, 2, 4])})
        with raises_regex(IndexError, "dimension coordinate 'x'"):
            da[dict(x=ind)] = value

        # consistent coordinate in the assigning values
        value = xr.DataArray(np.zeros((3, 3, 2)), dims=['x', 'y', 'z'],
                             coords={'x': [1, 2, 3],
                                     'non-dim': ('x', [0, 2, 4])})
        da[dict(x=ind)] = value
        assert np.allclose(da[dict(x=ind)].values, 0)
        assert_identical(da['x'], get_data()['x'])
        assert_identical(da['non-dim'], get_data()['non-dim'])

        # Conflict in the non-dimension coordinate
        value = xr.DataArray(np.zeros((3, 3, 2)), dims=['x', 'y', 'z'],
                             coords={'x': [1, 2, 3],
                                     'non-dim': ('x', [0, 2, 4])})
        da[dict(x=ind)] = value  # should not raise

        # conflict in the assigning values
        value = xr.DataArray(np.zeros((3, 3, 2)), dims=['x', 'y', 'z'],
                             coords={'x': [0, 1, 2],
                                     'non-dim': ('x', [0, 2, 4])})
        with raises_regex(IndexError, "dimension coordinate 'x'"):
            da[dict(x=ind)] = value

        # consistent coordinate in the assigning values
        value = xr.DataArray(np.zeros((3, 3, 2)), dims=['x', 'y', 'z'],
                             coords={'x': [1, 2, 3],
                                     'non-dim': ('x', [0, 2, 4])})
        da[dict(x=ind)] = value  # should not raise

    def test_contains(self):
        data_array = DataArray([1, 2])
        assert 1 in data_array
        assert 3 not in data_array

    def test_attr_sources_multiindex(self):
        # make sure attr-style access for multi-index levels
        # returns DataArray objects
        assert isinstance(self.mda.level_1, DataArray)

    def test_pickle(self):
        data = DataArray(np.random.random((3, 3)), dims=('id', 'time'))
        roundtripped = pickle.loads(pickle.dumps(data))
        assert_identical(data, roundtripped)

    @requires_dask
    def test_chunk(self):
        unblocked = DataArray(np.ones((3, 4)))
        assert unblocked.chunks is None

        blocked = unblocked.chunk()
        assert blocked.chunks == ((3,), (4,))

        blocked = unblocked.chunk(chunks=((2, 1), (2, 2)))
        assert blocked.chunks == ((2, 1), (2, 2))

        blocked = unblocked.chunk(chunks=(3, 3))
        assert blocked.chunks == ((3,), (3, 1))

        assert blocked.load().chunks is None

        # Check that kwargs are passed
        import dask.array as da
        blocked = unblocked.chunk(name_prefix='testname_')
        assert isinstance(blocked.data, da.Array)
        assert 'testname_' in blocked.data.name

    def test_isel(self):
        assert_identical(self.dv[0], self.dv.isel(x=0))
        assert_identical(self.dv, self.dv.isel(x=slice(None)))
        assert_identical(self.dv[:3], self.dv.isel(x=slice(3)))
        assert_identical(self.dv[:3, :5], self.dv.isel(x=slice(3), y=slice(5)))

    def test_isel_types(self):
        # regression test for #1405
        da = DataArray([1, 2, 3], dims='x')
        # uint64
        assert_identical(da.isel(x=np.array([0], dtype="uint64")),
                         da.isel(x=np.array([0])))
        # uint32
        assert_identical(da.isel(x=np.array([0], dtype="uint32")),
                         da.isel(x=np.array([0])))
        # int64
        assert_identical(da.isel(x=np.array([0], dtype="int64")),
                         da.isel(x=np.array([0])))

    @pytest.mark.filterwarnings('ignore::DeprecationWarning')
    def test_isel_fancy(self):
        shape = (10, 7, 6)
        np_array = np.random.random(shape)
        da = DataArray(np_array, dims=['time', 'y', 'x'],
                       coords={'time': np.arange(0, 100, 10)})
        y = [1, 3]
        x = [3, 0]

        expected = da.values[:, y, x]

        actual = da.isel(y=(('test_coord', ), y), x=(('test_coord', ), x))
        assert actual.coords['test_coord'].shape == (len(y), )
        assert list(actual.coords) == ['time']
        assert actual.dims == ('time', 'test_coord')

        np.testing.assert_equal(actual, expected)

        # a few corner cases
        da.isel(time=(('points',), [1, 2]), x=(('points',), [2, 2]),
                y=(('points',), [3, 4]))
        np.testing.assert_allclose(
            da.isel(time=(('p',), [1]),
                    x=(('p',), [2]),
                    y=(('p',), [4])).values.squeeze(),
            np_array[1, 4, 2].squeeze())
        da.isel(time=(('points', ), [1, 2]))
        y = [-1, 0]
        x = [-2, 2]
        expected = da.values[:, y, x]
        actual = da.isel(x=(('points', ), x), y=(('points', ), y)).values
        np.testing.assert_equal(actual, expected)

        # test that the order of the indexers doesn't matter
        assert_identical(
            da.isel(y=(('points', ), y), x=(('points', ), x)),
            da.isel(x=(('points', ), x), y=(('points', ), y)))

        # make sure we're raising errors in the right places
        with raises_regex(IndexError,
                          'Dimensions of indexers mismatch'):
            da.isel(y=(('points', ), [1, 2]), x=(('points', ), [1, 2, 3]))

        # tests using index or DataArray as indexers
        stations = Dataset()
        stations['station'] = (('station', ), ['A', 'B', 'C'])
        stations['dim1s'] = (('station', ), [1, 2, 3])
        stations['dim2s'] = (('station', ), [4, 5, 1])

        actual = da.isel(x=stations['dim1s'], y=stations['dim2s'])
        assert 'station' in actual.coords
        assert 'station' in actual.dims
        assert_identical(actual['station'], stations['station'])

        with raises_regex(ValueError, 'conflicting values for '):
            da.isel(x=DataArray([0, 1, 2], dims='station',
                                coords={'station': [0, 1, 2]}),
                    y=DataArray([0, 1, 2], dims='station',
                                coords={'station': [0, 1, 3]}))

        # multi-dimensional selection
        stations = Dataset()
        stations['a'] = (('a', ), ['A', 'B', 'C'])
        stations['b'] = (('b', ), [0, 1])
        stations['dim1s'] = (('a', 'b'), [[1, 2], [2, 3], [3, 4]])
        stations['dim2s'] = (('a', ), [4, 5, 1])

        actual = da.isel(x=stations['dim1s'], y=stations['dim2s'])
        assert 'a' in actual.coords
        assert 'a' in actual.dims
        assert 'b' in actual.coords
        assert 'b' in actual.dims
        assert_identical(actual['a'], stations['a'])
        assert_identical(actual['b'], stations['b'])
        expected = da.variable[:, stations['dim2s'].variable,
                               stations['dim1s'].variable]
        assert_array_equal(actual, expected)

    def test_sel(self):
        self.ds['x'] = ('x', np.array(list('abcdefghij')))
        da = self.ds['foo']
        assert_identical(da, da.sel(x=slice(None)))
        assert_identical(da[1], da.sel(x='b'))
        assert_identical(da[:3], da.sel(x=slice('c')))
        assert_identical(da[:3], da.sel(x=['a', 'b', 'c']))
        assert_identical(da[:, :4], da.sel(y=(self.ds['y'] < 4)))
        # verify that indexing with a dataarray works
        b = DataArray('b')
        assert_identical(da[1], da.sel(x=b))
        assert_identical(da[[1]], da.sel(x=slice(b, b)))

    def test_sel_dataarray(self):
        # indexing with DataArray
        self.ds['x'] = ('x', np.array(list('abcdefghij')))
        da = self.ds['foo']

        ind = DataArray(['a', 'b', 'c'], dims=['x'])
        actual = da.sel(x=ind)
        assert_identical(actual, da.isel(x=[0, 1, 2]))

        # along new dimension
        ind = DataArray(['a', 'b', 'c'], dims=['new_dim'])
        actual = da.sel(x=ind)
        assert_array_equal(actual, da.isel(x=[0, 1, 2]))
        assert 'new_dim' in actual.dims

        # with coordinate
        ind = DataArray(['a', 'b', 'c'], dims=['new_dim'],
                        coords={'new_dim': [0, 1, 2]})
        actual = da.sel(x=ind)
        assert_array_equal(actual, da.isel(x=[0, 1, 2]))
        assert 'new_dim' in actual.dims
        assert 'new_dim' in actual.coords
        assert_equal(actual['new_dim'].drop('x'), ind['new_dim'])

    def test_sel_invalid_slice(self):
        array = DataArray(np.arange(10), [('x', np.arange(10))])
        with raises_regex(ValueError, 'cannot use non-scalar arrays'):
            array.sel(x=slice(array.x))

    def test_sel_dataarray_datetime(self):
        # regression test for GH1240
        times = pd.date_range('2000-01-01', freq='D', periods=365)
        array = DataArray(np.arange(365), [('time', times)])
        result = array.sel(time=slice(array.time[0], array.time[-1]))
        assert_equal(result, array)

        array = DataArray(np.arange(365), [('delta', times - times[0])])
        result = array.sel(delta=slice(array.delta[0], array.delta[-1]))
        assert_equal(result, array)

    def test_sel_no_index(self):
        array = DataArray(np.arange(10), dims='x')
        assert_identical(array[0], array.sel(x=0))
        assert_identical(array[:5], array.sel(x=slice(5)))
        assert_identical(array[[0, -1]], array.sel(x=[0, -1]))
        assert_identical(
            array[array < 5], array.sel(x=(array < 5)))

    def test_sel_method(self):
        data = DataArray(np.random.randn(3, 4),
                         [('x', [0, 1, 2]), ('y', list('abcd'))])

        expected = data.sel(y=['a', 'b'])
        actual = data.sel(y=['ab', 'ba'], method='pad')
        assert_identical(expected, actual)

        expected = data.sel(x=[1, 2])
        actual = data.sel(x=[0.9, 1.9], method='backfill', tolerance=1)
        assert_identical(expected, actual)

    def test_sel_drop(self):
        data = DataArray([1, 2, 3], [('x', [0, 1, 2])])
        expected = DataArray(1)
        selected = data.sel(x=0, drop=True)
        assert_identical(expected, selected)

        expected = DataArray(1, {'x': 0})
        selected = data.sel(x=0, drop=False)
        assert_identical(expected, selected)

        data = DataArray([1, 2, 3], dims=['x'])
        expected = DataArray(1)
        selected = data.sel(x=0, drop=True)
        assert_identical(expected, selected)

    def test_isel_drop(self):
        data = DataArray([1, 2, 3], [('x', [0, 1, 2])])
        expected = DataArray(1)
        selected = data.isel(x=0, drop=True)
        assert_identical(expected, selected)

        expected = DataArray(1, {'x': 0})
        selected = data.isel(x=0, drop=False)
        assert_identical(expected, selected)

    @pytest.mark.filterwarnings("ignore:Dataset.isel_points")
    def test_isel_points(self):
        shape = (10, 5, 6)
        np_array = np.random.random(shape)
        da = DataArray(np_array, dims=['time', 'y', 'x'],
                       coords={'time': np.arange(0, 100, 10)})
        y = [1, 3]
        x = [3, 0]

        expected = da.values[:, y, x]

        actual = da.isel_points(y=y, x=x, dim='test_coord')
        assert actual.coords['test_coord'].shape == (len(y), )
        assert list(actual.coords) == ['time']
        assert actual.dims == ('test_coord', 'time')

        actual = da.isel_points(y=y, x=x)
        assert 'points' in actual.dims
        # Note that because xarray always concatenates along the first
        # dimension, We must transpose the result to match the numpy style of
        # concatenation.
        np.testing.assert_equal(actual.T, expected)

        # a few corner cases
        da.isel_points(time=[1, 2], x=[2, 2], y=[3, 4])
        np.testing.assert_allclose(
            da.isel_points(time=[1], x=[2], y=[4]).values.squeeze(),
            np_array[1, 4, 2].squeeze())
        da.isel_points(time=[1, 2])
        y = [-1, 0]
        x = [-2, 2]
        expected = da.values[:, y, x]
        actual = da.isel_points(x=x, y=y).values
        np.testing.assert_equal(actual.T, expected)

        # test that the order of the indexers doesn't matter
        assert_identical(
            da.isel_points(y=y, x=x),
            da.isel_points(x=x, y=y))

        # make sure we're raising errors in the right places
        with raises_regex(ValueError,
                          'All indexers must be the same length'):
            da.isel_points(y=[1, 2], x=[1, 2, 3])
        with raises_regex(ValueError,
                          'dimension bad_key does not exist'):
            da.isel_points(bad_key=[1, 2])
        with raises_regex(TypeError, 'Indexers must be integers'):
            da.isel_points(y=[1.5, 2.2])
        with raises_regex(TypeError, 'Indexers must be integers'):
            da.isel_points(x=[1, 2, 3], y=slice(3))
        with raises_regex(ValueError,
                          'Indexers must be 1 dimensional'):
            da.isel_points(y=1, x=2)
        with raises_regex(ValueError,
                          'Existing dimension names are not'):
            da.isel_points(y=[1, 2], x=[1, 2], dim='x')

        # using non string dims
        actual = da.isel_points(y=[1, 2], x=[1, 2], dim=['A', 'B'])
        assert 'points' in actual.coords

    def test_loc(self):
        self.ds['x'] = ('x', np.array(list('abcdefghij')))
        da = self.ds['foo']
        assert_identical(da[:3], da.loc[:'c'])
        assert_identical(da[1], da.loc['b'])
        assert_identical(da[1], da.loc[{'x': 'b'}])
        assert_identical(da[1], da.loc['b', ...])
        assert_identical(da[:3], da.loc[['a', 'b', 'c']])
        assert_identical(da[:3, :4], da.loc[['a', 'b', 'c'], np.arange(4)])
        assert_identical(da[:, :4], da.loc[:, self.ds['y'] < 4])

    def test_loc_assign(self):
        self.ds['x'] = ('x', np.array(list('abcdefghij')))
        da = self.ds['foo']
        # assignment
        da.loc['a':'j'] = 0
        assert np.all(da.values == 0)
        da.loc[{'x': slice('a', 'j')}] = 2
        assert np.all(da.values == 2)

        da.loc[{'x': slice('a', 'j')}] = 2
        assert np.all(da.values == 2)

        # Multi dimensional case
        da = DataArray(np.arange(12).reshape(3, 4), dims=['x', 'y'])
        da.loc[0, 0] = 0
        assert da.values[0, 0] == 0
        assert da.values[0, 1] != 0

        da = DataArray(np.arange(12).reshape(3, 4), dims=['x', 'y'])
        da.loc[0] = 0
        assert np.all(da.values[0] == np.zeros(4))
        assert da.values[1, 0] != 0

    def test_loc_assign_dataarray(self):
        def get_data():
            return DataArray(np.ones((4, 3, 2)), dims=['x', 'y', 'z'],
                             coords={'x': np.arange(4), 'y': ['a', 'b', 'c'],
                                     'non-dim': ('x', [1, 3, 4, 2])})

        da = get_data()
        # indexer with inconsistent coordinates.
        ind = DataArray(np.arange(1, 4), dims=['y'],
                        coords={'y': np.random.randn(3)})
        with raises_regex(IndexError, "dimension coordinate 'y'"):
            da.loc[dict(x=ind)] = 0

        # indexer with consistent coordinates.
        ind = DataArray(np.arange(1, 4), dims=['x'],
                        coords={'x': np.arange(1, 4)})
        da.loc[dict(x=ind)] = 0  # should not raise
        assert np.allclose(da[dict(x=ind)].values, 0)
        assert_identical(da['x'], get_data()['x'])
        assert_identical(da['non-dim'], get_data()['non-dim'])

        da = get_data()
        # conflict in the assigning values
        value = xr.DataArray(np.zeros((3, 3, 2)), dims=['x', 'y', 'z'],
                             coords={'x': [0, 1, 2],
                                     'non-dim': ('x', [0, 2, 4])})
        with raises_regex(IndexError, "dimension coordinate 'x'"):
            da.loc[dict(x=ind)] = value

        # consistent coordinate in the assigning values
        value = xr.DataArray(np.zeros((3, 3, 2)), dims=['x', 'y', 'z'],
                             coords={'x': [1, 2, 3],
                                     'non-dim': ('x', [0, 2, 4])})
        da.loc[dict(x=ind)] = value
        assert np.allclose(da[di
```


# xarray/tests/test_dataset.py

```
# -*- coding: utf-8 -*-
import pickle
import sys
import warnings
from collections import OrderedDict
from copy import copy, deepcopy
from io import StringIO
from textwrap import dedent

import numpy as np
import pandas as pd
import pytest

import xarray as xr
from xarray import (
    ALL_DIMS, DataArray, Dataset, IndexVariable, MergeError, Variable, align,
    backends, broadcast, open_dataset, set_options)
from xarray.core import dtypes, indexing, npcompat, utils
from xarray.core.common import duck_array_ops, full_like
from xarray.core.pycompat import integer_types

from . import (
    LooseVersion, InaccessibleArray, UnexpectedDataAccess, assert_allclose,
    assert_array_equal, assert_equal, assert_identical, has_cftime, has_dask,
    raises_regex, requires_bottleneck, requires_cftime, requires_dask,
    requires_numbagg, requires_scipy, source_ndarray)

try:
    import dask.array as da
except ImportError:
    pass


def create_test_data(seed=None):
    rs = np.random.RandomState(seed)
    _vars = {'var1': ['dim1', 'dim2'],
             'var2': ['dim1', 'dim2'],
             'var3': ['dim3', 'dim1']}
    _dims = {'dim1': 8, 'dim2': 9, 'dim3': 10}

    obj = Dataset()
    obj['time'] = ('time', pd.date_range('2000-01-01', periods=20))
    obj['dim2'] = ('dim2', 0.5 * np.arange(_dims['dim2']))
    obj['dim3'] = ('dim3', list('abcdefghij'))
    for v, dims in sorted(_vars.items()):
        data = rs.normal(size=tuple(_dims[d] for d in dims))
        obj[v] = (dims, data, {'foo': 'variable'})
    obj.coords['numbers'] = ('dim3', np.array([0, 1, 2, 0, 0, 1, 1, 2, 2, 3],
                                              dtype='int64'))
    obj.encoding = {'foo': 'bar'}
    assert all(obj.data.flags.writeable for obj in obj.variables.values())
    return obj


def create_append_test_data(seed=None):
    rs = np.random.RandomState(seed)

    lat = [2, 1, 0]
    lon = [0, 1, 2]
    nt1 = 3
    nt2 = 2
    time1 = pd.date_range('2000-01-01', periods=nt1)
    time2 = pd.date_range('2000-02-01', periods=nt2)
    string_var = np.array(["ae", "bc", "df"], dtype=object)
    string_var_to_append = np.array(['asdf', 'asdfg'], dtype=object)
    unicode_var = ["áó", "áó", "áó"]

    ds = xr.Dataset(
        data_vars={
            'da': xr.DataArray(rs.rand(3, 3, nt1), coords=[lat, lon, time1],
                               dims=['lat', 'lon', 'time']),
            'string_var': xr.DataArray(string_var, coords=[time1],
                                       dims=['time']),
            'unicode_var': xr.DataArray(unicode_var, coords=[time1],
                                        dims=['time']).astype(np.unicode_)
        }
    )

    ds_to_append = xr.Dataset(
        data_vars={
            'da': xr.DataArray(rs.rand(3, 3, nt2), coords=[lat, lon, time2],
                               dims=['lat', 'lon', 'time']),
            'string_var': xr.DataArray(string_var_to_append, coords=[time2],
                                       dims=['time']),
            'unicode_var': xr.DataArray(unicode_var[:nt2], coords=[time2],
                                        dims=['time']).astype(np.unicode_)
        }
    )

    ds_with_new_var = xr.Dataset(
        data_vars={
            'new_var': xr.DataArray(
                rs.rand(3, 3, nt1 + nt2),
                coords=[lat, lon, time1.append(time2)],
                dims=['lat', 'lon', 'time']
            ),
        }
    )

    assert all(objp.data.flags.writeable for objp in ds.variables.values())
    assert all(
        objp.data.flags.writeable for objp in ds_to_append.variables.values()
    )
    return ds, ds_to_append, ds_with_new_var


def create_test_multiindex():
    mindex = pd.MultiIndex.from_product([['a', 'b'], [1, 2]],
                                        names=('level_1', 'level_2'))
    return Dataset({}, {'x': mindex})


def create_test_stacked_array():
    x = DataArray(pd.Index(np.r_[:10], name='x'))
    y = DataArray(pd.Index(np.r_[:20], name='y'))
    a = x * y
    b = x * y * y
    return a, b


class InaccessibleVariableDataStore(backends.InMemoryDataStore):
    def __init__(self):
        super().__init__()
        self._indexvars = set()

    def store(self, variables, *args, **kwargs):
        super().store(variables, *args, **kwargs)
        for k, v in variables.items():
            if isinstance(v, IndexVariable):
                self._indexvars.add(k)

    def get_variables(self):
        def lazy_inaccessible(k, v):
            if k in self._indexvars:
                return v
            data = indexing.LazilyOuterIndexedArray(
                InaccessibleArray(v.values))
            return Variable(v.dims, data, v.attrs)
        return dict((k, lazy_inaccessible(k, v)) for
                    k, v in self._variables.items())


class TestDataset:
    def test_repr(self):
        data = create_test_data(seed=123)
        data.attrs['foo'] = 'bar'
        # need to insert str dtype at runtime to handle both Python 2 & 3
        expected = dedent("""\
        <xarray.Dataset>
        Dimensions:  (dim1: 8, dim2: 9, dim3: 10, time: 20)
        Coordinates:
          * time     (time) datetime64[ns] 2000-01-01 2000-01-02 ... 2000-01-20
          * dim2     (dim2) float64 0.0 0.5 1.0 1.5 2.0 2.5 3.0 3.5 4.0
          * dim3     (dim3) %s 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j'
            numbers  (dim3) int64 0 1 2 0 0 1 1 2 2 3
        Dimensions without coordinates: dim1
        Data variables:
            var1     (dim1, dim2) float64 -1.086 0.9973 0.283 ... 0.1995 0.4684 -0.8312
            var2     (dim1, dim2) float64 1.162 -1.097 -2.123 ... 0.1302 1.267 0.3328
            var3     (dim3, dim1) float64 0.5565 -0.2121 0.4563 ... -0.2452 -0.3616
        Attributes:
            foo:      bar""") % data['dim3'].dtype  # noqa: E501
        actual = '\n'.join(x.rstrip() for x in repr(data).split('\n'))
        print(actual)
        assert expected == actual

        with set_options(display_width=100):
            max_len = max(map(len, repr(data).split('\n')))
            assert 90 < max_len < 100

        expected = dedent("""\
        <xarray.Dataset>
        Dimensions:  ()
        Data variables:
            *empty*""")
        actual = '\n'.join(x.rstrip() for x in repr(Dataset()).split('\n'))
        print(actual)
        assert expected == actual

        # verify that ... doesn't appear for scalar coordinates
        data = Dataset({'foo': ('x', np.ones(10))}).mean()
        expected = dedent("""\
        <xarray.Dataset>
        Dimensions:  ()
        Data variables:
            foo      float64 1.0""")
        actual = '\n'.join(x.rstrip() for x in repr(data).split('\n'))
        print(actual)
        assert expected == actual

        # verify long attributes are truncated
        data = Dataset(attrs={'foo': 'bar' * 1000})
        assert len(repr(data)) < 1000

    def test_repr_multiindex(self):
        data = create_test_multiindex()
        expected = dedent("""\
        <xarray.Dataset>
        Dimensions:  (x: 4)
        Coordinates:
          * x        (x) MultiIndex
          - level_1  (x) object 'a' 'a' 'b' 'b'
          - level_2  (x) int64 1 2 1 2
        Data variables:
            *empty*""")
        actual = '\n'.join(x.rstrip() for x in repr(data).split('\n'))
        print(actual)
        assert expected == actual

        # verify that long level names are not truncated
        mindex = pd.MultiIndex.from_product(
            [['a', 'b'], [1, 2]],
            names=('a_quite_long_level_name', 'level_2'))
        data = Dataset({}, {'x': mindex})
        expected = dedent("""\
        <xarray.Dataset>
        Dimensions:                  (x: 4)
        Coordinates:
          * x                        (x) MultiIndex
          - a_quite_long_level_name  (x) object 'a' 'a' 'b' 'b'
          - level_2                  (x) int64 1 2 1 2
        Data variables:
            *empty*""")
        actual = '\n'.join(x.rstrip() for x in repr(data).split('\n'))
        print(actual)
        assert expected == actual

    def test_repr_period_index(self):
        data = create_test_data(seed=456)
        data.coords['time'] = pd.period_range(
            '2000-01-01', periods=20, freq='B')

        # check that creating the repr doesn't raise an error #GH645
        repr(data)

    def test_unicode_data(self):
        # regression test for GH834
        data = Dataset({'foø': ['ba®']}, attrs={'å': '∑'})
        repr(data)  # should not raise

        byteorder = '<' if sys.byteorder == 'little' else '>'
        expected = dedent(u"""\
        <xarray.Dataset>
        Dimensions:  (foø: 1)
        Coordinates:
          * foø      (foø) %cU3 %r
        Data variables:
            *empty*
        Attributes:
            å:        ∑""" % (byteorder, 'ba®'))
        actual = str(data)
        assert expected == actual

    def test_info(self):
        ds = create_test_data(seed=123)
        ds = ds.drop('dim3')  # string type prints differently in PY2 vs PY3
        ds.attrs['unicode_attr'] = 'ba®'
        ds.attrs['string_attr'] = 'bar'

        buf = StringIO()
        ds.info(buf=buf)

        expected = dedent('''\
        xarray.Dataset {
        dimensions:
        \tdim1 = 8 ;
        \tdim2 = 9 ;
        \tdim3 = 10 ;
        \ttime = 20 ;

        variables:
        \tdatetime64[ns] time(time) ;
        \tfloat64 dim2(dim2) ;
        \tfloat64 var1(dim1, dim2) ;
        \t\tvar1:foo = variable ;
        \tfloat64 var2(dim1, dim2) ;
        \t\tvar2:foo = variable ;
        \tfloat64 var3(dim3, dim1) ;
        \t\tvar3:foo = variable ;
        \tint64 numbers(dim3) ;

        // global attributes:
        \t:unicode_attr = ba® ;
        \t:string_attr = bar ;
        }''')
        actual = buf.getvalue()
        assert expected == actual
        buf.close()

    def test_constructor(self):
        x1 = ('x', 2 * np.arange(100))
        x2 = ('x', np.arange(1000))
        z = (['x', 'y'], np.arange(1000).reshape(100, 10))

        with raises_regex(ValueError, 'conflicting sizes'):
            Dataset({'a': x1, 'b': x2})
        with raises_regex(ValueError, "disallows such variables"):
            Dataset({'a': x1, 'x': z})
        with raises_regex(TypeError, 'tuple of form'):
            Dataset({'x': (1, 2, 3, 4, 5, 6, 7)})
        with raises_regex(ValueError, 'already exists as a scalar'):
            Dataset({'x': 0, 'y': ('x', [1, 2, 3])})

        # verify handling of DataArrays
        expected = Dataset({'x': x1, 'z': z})
        actual = Dataset({'z': expected['z']})
        assert_identical(expected, actual)

    def test_constructor_invalid_dims(self):
        # regression for GH1120
        with pytest.raises(MergeError):
            Dataset(data_vars=dict(v=('y', [1, 2, 3, 4])),
                    coords=dict(y=DataArray([.1, .2, .3, .4], dims='x')))

    def test_constructor_1d(self):
        expected = Dataset({'x': (['x'], 5.0 + np.arange(5))})
        actual = Dataset({'x': 5.0 + np.arange(5)})
        assert_identical(expected, actual)

        actual = Dataset({'x': [5, 6, 7, 8, 9]})
        assert_identical(expected, actual)

    def test_constructor_0d(self):
        expected = Dataset({'x': ([], 1)})
        for arg in [1, np.array(1), expected['x']]:
            actual = Dataset({'x': arg})
            assert_identical(expected, actual)

        class Arbitrary:
            pass

        d = pd.Timestamp('2000-01-01T12')
        args = [True, None, 3.4, np.nan, 'hello', b'raw',
                np.datetime64('2000-01-01'), d, d.to_pydatetime(),
                Arbitrary()]
        for arg in args:
            print(arg)
            expected = Dataset({'x': ([], arg)})
            actual = Dataset({'x': arg})
            assert_identical(expected, actual)

    def test_constructor_deprecated(self):
        with raises_regex(ValueError, 'DataArray dimensions'):
            DataArray([1, 2, 3], coords={'x': [0, 1, 2]})

    def test_constructor_auto_align(self):
        a = DataArray([1, 2], [('x', [0, 1])])
        b = DataArray([3, 4], [('x', [1, 2])])

        # verify align uses outer join
        expected = Dataset({'a': ('x', [1, 2, np.nan]),
                            'b': ('x', [np.nan, 3, 4])},
                           {'x': [0, 1, 2]})
        actual = Dataset({'a': a, 'b': b})
        assert_identical(expected, actual)

        # regression test for GH346
        assert isinstance(actual.variables['x'], IndexVariable)

        # variable with different dimensions
        c = ('y', [3, 4])
        expected2 = expected.merge({'c': c})
        actual = Dataset({'a': a, 'b': b, 'c': c})
        assert_identical(expected2, actual)

        # variable that is only aligned against the aligned variables
        d = ('x', [3, 2, 1])
        expected3 = expected.merge({'d': d})
        actual = Dataset({'a': a, 'b': b, 'd': d})
        assert_identical(expected3, actual)

        e = ('x', [0, 0])
        with raises_regex(ValueError, 'conflicting sizes'):
            Dataset({'a': a, 'b': b, 'e': e})

    def test_constructor_pandas_sequence(self):

        ds = self.make_example_math_dataset()
        pandas_objs = OrderedDict(
            (var_name, ds[var_name].to_pandas()) for var_name in ['foo', 'bar']
        )
        ds_based_on_pandas = Dataset(pandas_objs, ds.coords, attrs=ds.attrs)
        del ds_based_on_pandas['x']
        assert_equal(ds, ds_based_on_pandas)

        # reindex pandas obj, check align works
        rearranged_index = reversed(pandas_objs['foo'].index)
        pandas_objs['foo'] = pandas_objs['foo'].reindex(rearranged_index)
        ds_based_on_pandas = Dataset(pandas_objs, ds.coords, attrs=ds.attrs)
        del ds_based_on_pandas['x']
        assert_equal(ds, ds_based_on_pandas)

    def test_constructor_pandas_single(self):

        das = [
            DataArray(np.random.rand(4), dims=['a']),  # series
            DataArray(np.random.rand(4, 3), dims=['a', 'b']),  # df
        ]

        if LooseVersion(pd.__version__) < '0.25.0':
            das.append(
                DataArray(np.random.rand(4, 3, 2), dims=['a', 'b', 'c']))

        with warnings.catch_warnings():
            warnings.filterwarnings('ignore', r'\W*Panel is deprecated')
            for a in das:
                pandas_obj = a.to_pandas()
                ds_based_on_pandas = Dataset(pandas_obj)
                for dim in ds_based_on_pandas.data_vars:
                    assert_array_equal(
                        ds_based_on_pandas[dim], pandas_obj[dim])

    def test_constructor_compat(self):
        data = OrderedDict([('x', DataArray(0, coords={'y': 1})),
                            ('y', ('z', [1, 1, 1]))])
        expected = Dataset({'x': 0}, {'y': ('z', [1, 1, 1])})
        actual = Dataset(data)
        assert_identical(expected, actual)

        data = OrderedDict([('y', ('z', [1, 1, 1])),
                            ('x', DataArray(0, coords={'y': 1}))])
        actual = Dataset(data)
        assert_identical(expected, actual)

        original = Dataset({'a': (('x', 'y'), np.ones((2, 3)))},
                           {'c': (('x', 'y'), np.zeros((2, 3))), 'x': [0, 1]})
        expected = Dataset({'a': ('x', np.ones(2)),
                            'b': ('y', np.ones(3))},
                           {'c': (('x', 'y'), np.zeros((2, 3))), 'x': [0, 1]})
        # use an OrderedDict to ensure test results are reproducible; otherwise
        # the order of appearance of x and y matters for the order of
        # dimensions in 'c'
        actual = Dataset(OrderedDict([('a', original['a'][:, 0]),
                                      ('b', original['a'][0].drop('x'))]))
        assert_identical(expected, actual)

        data = {'x': DataArray(0, coords={'y': 3}), 'y': ('z', [1, 1, 1])}
        with pytest.raises(MergeError):
            Dataset(data)

        data = {'x': DataArray(0, coords={'y': 1}), 'y': [1, 1]}
        actual = Dataset(data)
        expected = Dataset({'x': 0}, {'y': [1, 1]})
        assert_identical(expected, actual)

    def test_constructor_with_coords(self):
        with raises_regex(ValueError, 'found in both data_vars and'):
            Dataset({'a': ('x', [1])}, {'a': ('x', [1])})

        ds = Dataset({}, {'a': ('x', [1])})
        assert not ds.data_vars
        assert list(ds.coords.keys()) == ['a']

        mindex = pd.MultiIndex.from_product([['a', 'b'], [1, 2]],
                                            names=('level_1', 'level_2'))
        with raises_regex(ValueError, 'conflicting MultiIndex'):
            Dataset({}, {'x': mindex, 'y': mindex})
            Dataset({}, {'x': mindex, 'level_1': range(4)})

    def test_properties(self):
        ds = create_test_data()
        assert ds.dims == \
            {'dim1': 8, 'dim2': 9, 'dim3': 10, 'time': 20}
        assert list(ds.dims) == sorted(ds.dims)
        assert ds.sizes == ds.dims

        # These exact types aren't public API, but this makes sure we don't
        # change them inadvertently:
        assert isinstance(ds.dims, utils.Frozen)
        assert isinstance(ds.dims.mapping, utils.SortedKeysDict)
        assert type(ds.dims.mapping.mapping) is dict  # noqa

        assert list(ds) == list(ds.data_vars)
        assert list(ds.keys()) == list(ds.data_vars)
        assert 'aasldfjalskdfj' not in ds.variables
        assert 'dim1' in repr(ds.variables)
        assert len(ds) == 3
        assert bool(ds)

        assert list(ds.data_vars) == ['var1', 'var2', 'var3']
        assert list(ds.data_vars.keys()) == ['var1', 'var2', 'var3']
        assert 'var1' in ds.data_vars
        assert 'dim1' not in ds.data_vars
        assert 'numbers' not in ds.data_vars
        assert len(ds.data_vars) == 3

        assert set(ds.indexes) == {'dim2', 'dim3', 'time'}
        assert len(ds.indexes) == 3
        assert 'dim2' in repr(ds.indexes)

        assert list(ds.coords) == ['time', 'dim2', 'dim3', 'numbers']
        assert 'dim2' in ds.coords
        assert 'numbers' in ds.coords
        assert 'var1' not in ds.coords
        assert 'dim1' not in ds.coords
        assert len(ds.coords) == 4

        assert Dataset({'x': np.int64(1),
                        'y': np.float32([1, 2])}).nbytes == 16

    def test_asarray(self):
        ds = Dataset({'x': 0})
        with raises_regex(TypeError, 'cannot directly convert'):
            np.asarray(ds)

    def test_get_index(self):
        ds = Dataset({'foo': (('x', 'y'), np.zeros((2, 3)))},
                     coords={'x': ['a', 'b']})
        assert ds.get_index('x').equals(pd.Index(['a', 'b']))
        assert ds.get_index('y').equals(pd.Index([0, 1, 2]))
        with pytest.raises(KeyError):
            ds.get_index('z')

    def test_attr_access(self):
        ds = Dataset({'tmin': ('x', [42], {'units': 'Celcius'})},
                     attrs={'title': 'My test data'})
        assert_identical(ds.tmin, ds['tmin'])
        assert_identical(ds.tmin.x, ds.x)

        assert ds.title == ds.attrs['title']
        assert ds.tmin.units == ds['tmin'].attrs['units']

        assert set(['tmin', 'title']) <= set(dir(ds))
        assert 'units' in set(dir(ds.tmin))

        # should defer to variable of same name
        ds.attrs['tmin'] = -999
        assert ds.attrs['tmin'] == -999
        assert_identical(ds.tmin, ds['tmin'])

    def test_variable(self):
        a = Dataset()
        d = np.random.random((10, 3))
        a['foo'] = (('time', 'x',), d)
        assert 'foo' in a.variables
        assert 'foo' in a
        a['bar'] = (('time', 'x',), d)
        # order of creation is preserved
        assert list(a.variables) == ['foo', 'bar']
        assert_array_equal(a['foo'].values, d)
        # try to add variable with dim (10,3) with data that's (3,10)
        with pytest.raises(ValueError):
            a['qux'] = (('time', 'x'), d.T)

    def test_modify_inplace(self):
        a = Dataset()
        vec = np.random.random((10,))
        attributes = {'foo': 'bar'}
        a['x'] = ('x', vec, attributes)
        assert 'x' in a.coords
        assert isinstance(a.coords['x'].to_index(), pd.Index)
        assert_identical(a.coords['x'].variable, a.variables['x'])
        b = Dataset()
        b['x'] = ('x', vec, attributes)
        assert_identical(a['x'], b['x'])
        assert a.dims == b.dims
        # this should work
        a['x'] = ('x', vec[:5])
        a['z'] = ('x', np.arange(5))
        with pytest.raises(ValueError):
            # now it shouldn't, since there is a conflicting length
            a['x'] = ('x', vec[:4])
        arr = np.random.random((10, 1,))
        scal = np.array(0)
        with pytest.raises(ValueError):
            a['y'] = ('y', arr)
        with pytest.raises(ValueError):
            a['y'] = ('y', scal)
        assert 'y' not in a.dims

    def test_coords_properties(self):
        # use an OrderedDict for coordinates to ensure order across python
        # versions
        # use int64 for repr consistency on windows
        data = Dataset(OrderedDict([('x', ('x', np.array([-1, -2], 'int64'))),
                                    ('y', ('y', np.array([0, 1, 2], 'int64'))),
                                    ('foo', (['x', 'y'],
                                             np.random.randn(2, 3)))]),
                       OrderedDict([('a', ('x', np.array([4, 5], 'int64'))),
                                    ('b', np.int64(-10))]))

        assert 4 == len(data.coords)

        assert ['x', 'y', 'a', 'b'] == list(data.coords)

        assert_identical(data.coords['x'].variable, data['x'].variable)
        assert_identical(data.coords['y'].variable, data['y'].variable)

        assert 'x' in data.coords
        assert 'a' in data.coords
        assert 0 not in data.coords
        assert 'foo' not in data.coords

        with pytest.raises(KeyError):
            data.coords['foo']
        with pytest.raises(KeyError):
            data.coords[0]

        expected = dedent("""\
        Coordinates:
          * x        (x) int64 -1 -2
          * y        (y) int64 0 1 2
            a        (x) int64 4 5
            b        int64 -10""")
        actual = repr(data.coords)
        assert expected == actual

        assert {'x': 2, 'y': 3} == data.coords.dims

    def test_coords_modify(self):
        data = Dataset({'x': ('x', [-1, -2]),
                        'y': ('y', [0, 1, 2]),
                        'foo': (['x', 'y'], np.random.randn(2, 3))},
                       {'a': ('x', [4, 5]), 'b': -10})

        actual = data.copy(deep=True)
        actual.coords['x'] = ('x', ['a', 'b'])
        assert_array_equal(actual['x'], ['a', 'b'])

        actual = data.copy(deep=True)
        actual.coords['z'] = ('z', ['a', 'b'])
        assert_array_equal(actual['z'], ['a', 'b'])

        actual = data.copy(deep=True)
        with raises_regex(ValueError, 'conflicting sizes'):
            actual.coords['x'] = ('x', [-1])
        assert_identical(actual, data)  # should not be modified

        actual = data.copy()
        del actual.coords['b']
        expected = data.reset_coords('b', drop=True)
        assert_identical(expected, actual)

        with pytest.raises(KeyError):
            del data.coords['not_found']

        with pytest.raises(KeyError):
            del data.coords['foo']

        actual = data.copy(deep=True)
        actual.coords.update({'c': 11})
        expected = data.merge({'c': 11}).set_coords('c')
        assert_identical(expected, actual)

    def test_update_index(self):
        actual = Dataset(coords={'x': [1, 2, 3]})
        actual['x'] = ['a', 'b', 'c']
        assert actual.indexes['x'].equals(pd.Index(['a', 'b', 'c']))

    def test_coords_setitem_with_new_dimension(self):
        actual = Dataset()
        actual.coords['foo'] = ('x', [1, 2, 3])
        expected = Dataset(coords={'foo': ('x', [1, 2, 3])})
        assert_identical(expected, actual)

    def test_coords_setitem_multiindex(self):
        data = create_test_multiindex()
        with raises_regex(ValueError, 'conflicting MultiIndex'):
            data.coords['level_1'] = range(4)

    def test_coords_set(self):
        one_coord = Dataset({'x': ('x', [0]),
                             'yy': ('x', [1]),
                             'zzz': ('x', [2])})
        two_coords = Dataset({'zzz': ('x', [2])},
                             {'x': ('x', [0]),
                              'yy': ('x', [1])})
        all_coords = Dataset(coords={'x': ('x', [0]),
                                     'yy': ('x', [1]),
                                     'zzz': ('x', [2])})

        actual = one_coord.set_coords('x')
        assert_identical(one_coord, actual)
        actual = one_coord.set_coords(['x'])
        assert_identical(one_coord, actual)

        actual = one_coord.set_coords('yy')
        assert_identical(two_coords, actual)

        actual = one_coord.set_coords(['yy', 'zzz'])
        assert_identical(all_coords, actual)

        actual = one_coord.reset_coords()
        assert_identical(one_coord, actual)
        actual = two_coords.reset_coords()
        assert_identical(one_coord, actual)
        actual = all_coords.reset_coords()
        assert_identical(one_coord, actual)

        actual = all_coords.reset_coords(['yy', 'zzz'])
        assert_identical(one_coord, actual)
        actual = all_coords.reset_coords('zzz')
        assert_identical(two_coords, actual)

        with raises_regex(ValueError, 'cannot remove index'):
            one_coord.reset_coords('x')

        actual = all_coords.reset_coords('zzz', drop=True)
        expected = all_coords.drop('zzz')
        assert_identical(expected, actual)
        expected = two_coords.drop('zzz')
        assert_identical(expected, actual)

    def test_coords_to_dataset(self):
        orig = Dataset({'foo': ('y', [-1, 0, 1])}, {'x': 10, 'y': [2, 3, 4]})
        expected = Dataset(coords={'x': 10, 'y': [2, 3, 4]})
        actual = orig.coords.to_dataset()
        assert_identical(expected, actual)

    def test_coords_merge(self):
        orig_coords = Dataset(coords={'a': ('x', [1, 2]), 'x': [0, 1]}).coords
        other_coords = Dataset(coords={'b': ('x', ['a', 'b']),
                                       'x': [0, 1]}).coords
        expected = Dataset(coords={'a': ('x', [1, 2]),
                                   'b': ('x', ['a', 'b']),
                                   'x': [0, 1]})
        actual = orig_coords.merge(other_coords)
        assert_identical(expected, actual)
        actual = other_coords.merge(orig_coords)
        assert_identical(expected, actual)

        other_coords = Dataset(coords={'x': ('x', ['a'])}).coords
        with pytest.raises(MergeError):
            orig_coords.merge(other_coords)
        other_coords = Dataset(coords={'x': ('x', ['a', 'b'])}).coords
        with pytest.raises(MergeError):
            orig_coords.merge(other_coords)
        other_coords = Dataset(coords={'x': ('x', ['a', 'b', 'c'])}).coords
        with pytest.raises(MergeError):
            orig_coords.merge(other_coords)

        other_coords = Dataset(coords={'a': ('x', [8, 9])}).coords
        expected = Dataset(coords={'x': range(2)})
        actual = orig_coords.merge(other_coords)
        assert_identical(expected, actual)
        actual = other_coords.merge(orig_coords)
        assert_identical(expected, actual)

        other_coords = Dataset(coords={'x': np.nan}).coords
        actual = orig_coords.merge(other_coords)
        assert_identical(orig_coords.to_dataset(), actual)
        actual = other_coords.merge(orig_coords)
        assert_identical(orig_coords.to_dataset(), actual)

    def test_coords_merge_mismatched_shape(self):
        orig_coords = Dataset(coords={'a': ('x', [1, 1])}).coords
        other_coords = Dataset(coords={'a': 1}).coords
        expected = orig_coords.to_dataset()
        actual = orig_coords.merge(other_coords)
        assert_identical(expected, actual)

        other_coords = Dataset(coords={'a': ('y', [1])}).coords
        expected = Dataset(coords={'a': (['x', 'y'], [[1], [1]])})
        actual = orig_coords.merge(other_coords)
        assert_identical(expected, actual)

        actual = other_coords.merge(orig_coords)
        assert_identical(expected.transpose(), actual)

        orig_coords = Dataset(coords={'a': ('x', [np.nan])}).coords
        other_coords = Dataset(coords={'a': np.nan}).coords
        expected = orig_coords.to_dataset()
        actual = orig_coords.merge(other_coords)
        assert_identical(expected, actual)

    def test_data_vars_properties(self):
        ds = Dataset()
        ds['foo'] = (('x',), [1.0])
        ds['bar'] = 2.0

        assert set(ds.data_vars) == {'foo', 'bar'}
        assert 'foo' in ds.data_vars
        assert 'x' not in ds.data_vars
        assert_identical(ds['foo'], ds.data_vars['foo'])

        expected = dedent("""\
        Data variables:
            foo      (x) float64 1.0
            bar      float64 2.0""")
        actual = repr(ds.data_vars)
        assert expected == actual

    def test_equals_and_identical(self):
        data = create_test_data(seed=42)
        assert data.equals(data)
        assert data.identical(data)

        data2 = create_test_data(seed=42)
        data2.attrs['foobar'] = 'baz'
        assert data.equals(data2)
        assert not data.identical(data2)

        del data2['time']
        assert not data.equals(data2)

        data = create_test_data(seed=42).rename({'var1': None})
        assert data.equals(data)
        assert data.identical(data)

        data2 = data.reset_coords()
        assert not data2.equals(data)
        assert not data2.identical(data)

    def test_equals_failures(self):
        data = create_test_data()
        assert not data.equals('foo')
        assert not data.identical(123)
        assert not data.broadcast_equals({1: 2})

    def test_broadcast_equals(self):
        data1 = Dataset(coords={'x': 0})
        data2 = Dataset(coords={'x': [0]})
        assert data1.broadcast_equals(data2)
        assert not data1.equals(data2)
        assert not data1.identical(data2)

    def test_attrs(self):
        data = create_test_data(seed=42)
        data.attrs = {'foobar': 'baz'}
        assert data.attrs['foobar'], 'baz'
        assert isinstance(data.attrs, OrderedDict)

    @requires_dask
    def test_chunk(self):
        data = create_test_data()
        for v in data.variables.values():
            assert isinstance(v.data, np.ndarray)
        assert data.chunks == {}

        reblocked = data.chunk()
        for k, v in reblocked.variables.items():
            if k in reblocked.dims:
                assert isinstance(v.data, np.ndarray)
            else:
                assert isinstance(v.data, da.Array)

        expected_chunks = {'dim1': (8,), 'dim2': (9,), 'dim3': (10,)}
        assert reblocked.chunks == expected_chunks

        reblocked = data.chunk({'time': 5, 'dim1': 5, 'dim2': 5, 'dim3': 5})
        # time is not a dim in any of the data_vars, so it
        # doesn't get chunked
        expected_chunks = {'dim1': (5, 3), 'dim2': (5, 4), 'dim3': (5, 5)}
        assert reblocked.chunks == expected_chunks

        reblocked = data.chunk(expected_chunks)
        assert reblocked.chunks == expected_chunks

        # reblock on already blocked data
        reblocked = reblocked.chunk(expected_chunks)
        assert reblocked.chunks == expected_chunks
        assert_identical(reblocked, data)

        with raises_regex(ValueError, 'some chunks'):
            data.chunk({'foo': 10})

    @requires_dask
    def test_dask_is_lazy(self):
        store = InaccessibleVariableDataStore()
        create_test_data().dump_to_store(store)
        ds = open_dataset(store).chunk()

        with pytest.raises(UnexpectedDataAccess):
            ds.load()
        with pytest.raises(UnexpectedDataAccess):
            ds['var1'].values

        # these should not raise UnexpectedDataAccess:
        ds.var1.data
        ds.isel(time=10)
        ds.isel(time=slice(10), dim1=[0]).isel(dim1=0, dim2=-1)
        ds.transpose()
        ds.mean()
        ds.fillna(0)
        ds.rename({'dim1': 'foobar'})
        ds.set_coords('var1')
        ds.drop('var1')

    def test_isel(self):
        data = create_test_data()
        slicers = {'dim1': slice(None, None, 2), 'dim2': slice(0, 2)}
        ret = data.isel(**slicers)

        # Verify that only the specified dimension was altered
        assert list(data.dims) == list(ret.dims)
        for d in data.dims:
            if d in slicers:
                assert ret.dims[d] == \
                    np.arange(data.dims[d])[slicers[d]].size
            else:
                assert data.dims[d] == ret.dims[d]
        # Verify that the data is what we expect
        for v in data.variables:
            assert data[v].dims == ret[v].dims
            assert data[v].attrs == ret[v].attrs
            slice_list = [slice(None)] * data[v].values.ndim
            for d, s in slicers.items():
                if d in data[v].dims:
                    inds = np.nonzero(np.array(data[v].dims) == d)[0]
                    for ind in inds:
                        slice_list[ind] = s
            expected = data[v].values[tuple(slice_list)]
            actual = ret[v].values
            np.testing.assert_array_equal(expected, actual)

        with pytest.raises(ValueError):
            data.isel(not_a_dim=slice(0, 2))

        ret = data.isel(dim1=0)
        assert {'time': 20, 'dim2': 9, 'dim3': 10} == ret.dims
        assert set(data.data_vars) == set(ret.data_vars)
        assert set(data.coords) == set(ret.coords)
        assert set(data.indexes) == set(ret.indexes)

        ret = data.isel(time=slice(2), dim1=0, dim2=slice(5))
        assert {'time': 2, 'dim2': 5, 'dim3': 10} == ret.dims
        assert set(data.data_vars) == set(ret.data_vars)
        assert set(data.coords) == set(ret.coords)
        assert set(data.indexes) == set(ret.indexes)

        ret = data.isel(time=0, dim1=0, dim2=slice(5))
        assert {'dim2': 5, 'dim3': 10} == ret.dims
        assert set(data.data_vars) == set(ret.data_vars)
        assert set(data.coords) == set(ret.coords)
        assert set(data.indexes) == set(list(ret.indexes) + ['time'])

    def test_isel_fancy(self):
        # isel with fancy indexing.
        data = create_test_data()

        pdim1 = [1, 2, 3]
        pdim2 = [4, 5, 1]


[... 5661 more bytes of this file not shown ...]
````

### `direct-check.log`

```
check: pytest xarray/tests/test_variable.py xarray/tests/test_dataarray.py xarray/tests/test_dataset.py -q
........................................................................ [  4%]
........................................................................ [  8%]
....................xxxx................................................ [ 12%]
..................xxxxxxx............................................... [ 16%]
........................................................................ [ 20%]
................s.s..................................................... [ 24%]
......................XX................................................ [ 28%]
........................................................................ [ 32%]
........................................................................ [ 36%]
........................................................................ [ 40%]
........................................................................ [ 44%]
........................................................................ [ 48%]
........................................................................ [ 52%]
...............................................................XX....... [ 56%]
.F.....sF............................................................... [ 61%]
........................................................................ [ 65%]
............................F........................................... [ 69%]
........................................................................ [ 73%]
........................................................................ [ 77%]
...................................................................sssss [ 81%]
sssssssssss............................................................. [ 85%]
........................................................................ [ 89%]
........................................................................ [ 93%]
........................................................................ [ 97%]
..................................FF....FF                               [100%]
=================================== FAILURES ===================================
______________________ TestDataset.test_expand_dims_error ______________________

self = <xarray.tests.test_dataset.TestDataset object at 0x7678962abdf0>

    def test_expand_dims_error(self):
        original = Dataset({'x': ('a', np.random.randn(3)),
                            'y': (['b', 'a'], np.random.randn(4, 3)),
                            'z': ('a', np.random.randn(3))},
                           coords={'a': np.linspace(0, 1, 3),
                                   'b': np.linspace(0, 1, 4),
                                   'c': np.linspace(0, 1, 5)},
                           attrs={'key': 'entry'})
    
        with raises_regex(ValueError, 'already exists'):
            original.expand_dims(dim=['x'])
    
        # Make sure it raises true error also for non-dimensional coordinates
        # which has dimension.
        original = original.set_coords('z')
        with raises_regex(ValueError, 'already exists'):
            original.expand_dims(dim=['z'])
    
        original = Dataset({'x': ('a', np.random.randn(3)),
                            'y': (['b', 'a'], np.random.randn(4, 3)),
                            'z': ('a', np.random.randn(3))},
                           coords={'a': np.linspace(0, 1, 3),
                                   'b': np.linspace(0, 1, 4),
                                   'c': np.linspace(0, 1, 5)},
                           attrs={'key': 'entry'})
        with raises_regex(TypeError, 'value of new dimension'):
            original.expand_dims(OrderedDict((("d", 3.2),)))
    
        # TODO: only the code under the if-statement is needed when python 3.5
        #   is no longer supported.
        python36_plus = sys.version_info[0] == 3 and sys.version_info[1] > 5
        if python36_plus:
            with raises_regex(ValueError, 'both keyword and positional'):
>               original.expand_dims(OrderedDict((("d", 4),)), e=4)

xarray/tests/test_dataset.py:2283: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <xarray.Dataset>
Dimensions:  (a: 3, b: 4, c: 5)
Coordinates:
  * a        (a) float64 0.0 0.5 1.0
  * b        (b) fl...07 1.304 -0.7855 ... 1.416 0.7507 -0.5223
    z        (a) float64 -1.651 1.919 -0.2201
Attributes:
    key:      entry
dim = OrderedDict([('d', 4)]), axis = None, dim_kwargs = {'e': 4}

    def expand_dims(
        self,
        dim: Union[None, Hashable, Sequence[Hashable],
                   Mapping[Hashable, Any]] = None,
        axis: Union[None, int, Sequence[int]] = None,
        **dim_kwargs: Any
    ) -> 'Dataset':
        """Return a new object with an additional axis (or axes) inserted at
        the corresponding position in the array shape.  The new object is a
        view into the underlying array, not a copy.
    
        If dim is already a scalar coordinate, it will be promoted to a 1D
        coordinate consisting of a single value.
    
        Parameters
        ----------
        dim : hashable, sequence of hashable, mapping, or None
            Dimensions to include on the new variable. If provided as hashable
            or sequence of hashable, then dimensions are inserted with length
            1. If provided as a mapping, then the keys are the new dimensions
            and the values are either integers (giving the length of the new
            dimensions) or array-like (giving the coordinates of the new
            dimensions).
    
            .. note::
    
               For Python 3.5, if ``dim`` is a mapping, then it must be an
               ``OrderedDict``. This is to ensure that the order in which the
               dims are given is maintained.
    
        axis : integer, sequence of integers, or None
            Axis position(s) where new axis is to be inserted (position(s) on
            the result array). If a list (or tuple) of integers is passed,
            multiple axes are inserted. In this case, dim arguments should be
            same length list. If axis=None is passed, all the axes will be
            inserted to the start of the result array.
        **dim_kwargs : int or sequence/ndarray
            The keywords are arbitrary dimensions being inserted and the values
            are either the lengths of the new dims (if int is given), or their
            coordinates. Note, this is an alternative to passing a dict to the
            dim kwarg and will only be used if dim is None.
    
            .. note::
    
               For Python 3.5, ``dim_kwargs`` is not available.
    
        Returns
        -------
        expanded : same type as caller
            This object, but with an additional dimension(s).
        """
        # TODO: get rid of the below code block when python 3.5 is no longer
        #   supported.
        if sys.version < '3.6':
            if isinstance(dim, Mapping) and not isinstance(dim, OrderedDict):
                raise TypeError("dim must be an OrderedDict for python <3.6")
            if dim_kwargs:
>               raise ValueError("dim_kwargs isn't available for python <3.6")
E               ValueError: dim_kwargs isn't available for python <3.6

xarray/core/dataset.py:2659: ValueError

During handling of the above exception, another exception occurred:

self = <xarray.tests.test_dataset.TestDataset object at 0x7678962abdf0>

    def test_expand_dims_error(self):
        original = Dataset({'x': ('a', np.random.randn(3)),
                            'y': (['b', 'a'], np.random.randn(4, 3)),
                            'z': ('a', np.random.randn(3))},
                           coords={'a': np.linspace(0, 1, 3),
                                   'b': np.linspace(0, 1, 4),
                                   'c': np.linspace(0, 1, 5)},
                           attrs={'key': 'entry'})
    
        with raises_regex(ValueError, 'already exists'):
            original.expand_dims(dim=['x'])
    
        # Make sure it raises true error also for non-dimensional coordinates
        # which has dimension.
        original = original.set_coords('z')
        with raises_regex(ValueError, 'already exists'):
            original.expand_dims(dim=['z'])
    
        original = Dataset({'x': ('a', np.random.randn(3)),
                            'y': (['b', 'a'], np.random.randn(4, 3)),
                            'z': ('a', np.random.randn(3))},
                           coords={'a': np.linspace(0, 1, 3),
                                   'b': np.linspace(0, 1, 4),
                                   'c': np.linspace(0, 1, 5)},
                           attrs={'key': 'entry'})
        with raises_regex(TypeError, 'value of new dimension'):
            original.expand_dims(OrderedDict((("d", 3.2),)))
    
        # TODO: only the code under the if-statement is needed when python 3.5
        #   is no longer supported.
        python36_plus = sys.version_info[0] == 3 and sys.version_info[1] > 5
        if python36_plus:
>           with raises_regex(ValueError, 'both keyword and positional'):

xarray/tests/test_dataset.py:2282: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <contextlib._GeneratorContextManager object at 0x76788c710130>
typ = <class 'ValueError'>
value = ValueError("dim_kwargs isn't available for python <3.6")
traceback = <traceback object at 0x76788c714740>

    def __exit__(self, typ, value, traceback):
        if typ is None:
            try:
                next(self.gen)
            except StopIteration:
                return False
            else:
                raise RuntimeError("generator didn't stop")
        else:
            if value is None:
                # Need to force instantiation so we can reliably
                # tell if we get the same exception back
                value = typ()
            try:
>               self.gen.throw(typ, value, traceback)
E               AssertionError: exception ValueError("dim_kwargs isn't available for python <3.6") did not match pattern 'both keyword and positional'

/opt/miniconda3/envs/testbed/lib/python3.10/contextlib.py:153: AssertionError
_______________ TestDataset.test_expand_dims_kwargs_python36plus _______________

self = <xarray.tests.test_dataset.TestDataset object at 0x7678962cc610>

    @pytest.mark.skipif(
        sys.version_info[:2] < (3, 6),
        reason='keyword arguments are only ordered on Python 3.6+',
    )
    def test_expand_dims_kwargs_python36plus(self):
        original = Dataset({'x': ('a', np.random.randn(3)),
                            'y': (['b', 'a'], np.random.randn(4, 3))},
                           coords={'a': np.linspace(0, 1, 3),
                                   'b': np.linspace(0, 1, 4),
                                   'c': np.linspace(0, 1, 5)},
                           attrs={'key': 'entry'})
>       other_way = original.expand_dims(e=["l", "m", "n"])

xarray/tests/test_dataset.py:2389: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <xarray.Dataset>
Dimensions:  (a: 3, b: 4, c: 5)
Coordinates:
  * a        (a) float64 0.0 0.5 1.0
  * b        (b) fl....7868 1.415
    y        (b, a) float64 0.3711 -0.108 0.09274 ... -0.3713 -0.7551 0.369
Attributes:
    key:      entry
dim = None, axis = None, dim_kwargs = {'e': ['l', 'm', 'n']}

    def expand_dims(
        self,
        dim: Union[None, Hashable, Sequence[Hashable],
                   Mapping[Hashable, Any]] = None,
        axis: Union[None, int, Sequence[int]] = None,
        **dim_kwargs: Any
    ) -> 'Dataset':
        """Return a new object with an additional axis (or axes) inserted at
        the corresponding position in the array shape.  The new object is a
        view into the underlying array, not a copy.
    
        If dim is already a scalar coordinate, it will be promoted to a 1D
        coordinate consisting of a single value.
    
        Parameters
        ----------
        dim : hashable, sequence of hashable, mapping, or None
            Dimensions to include on the new variable. If provided as hashable
            or sequence of hashable, then dimensions are inserted with length
            1. If provided as a mapping, then the keys are the new dimensions
            and the values are either integers (giving the length of the new
            dimensions) or array-like (giving the coordinates of the new
            dimensions).
    
            .. note::
    
               For Python 3.5, if ``dim`` is a mapping, then it must be an
               ``OrderedDict``. This is to ensure that the order in which the
               dims are given is maintained.
    
        axis : integer, sequence of integers, or None
            Axis position(s) where new axis is to be inserted (position(s) on
            the result array). If a list (or tuple) of integers is passed,
            multiple axes are inserted. In this case, dim arguments should be
            same length list. If axis=None is passed, all the axes will be
            inserted to the start of the result array.
        **dim_kwargs : int or sequence/ndarray
            The keywords are arbitrary dimensions being inserted and the values
            are either the lengths of the new dims (if int is given), or their
            coordinates. Note, this is an alternative to passing a dict to the
            dim kwarg and will only be used if dim is None.
    
            .. note::
    
               For Python 3.5, ``dim_kwargs`` is not available.
    
        Returns
        -------
        expanded : same type as caller
            This object, but with an additional dimension(s).
        """
        # TODO: get rid of the below code block when python 3.5 is no longer
        #   supported.
        if sys.version < '3.6':
            if isinstance(dim, Mapping) and not isinstance(dim, OrderedDict):
                raise TypeError("dim must be an OrderedDict for python <3.6")
            if dim_kwargs:
>               raise ValueError("dim_kwargs isn't available for python <3.6")
E               ValueError: dim_kwargs isn't available for python <3.6

xarray/core/dataset.py:2659: ValueError
__________________________ test_coarsen_coords_cftime __________________________

    @requires_cftime
    def test_coarsen_coords_cftime():
>       times = xr.cftime_range('2000', periods=6)

xarray/tests/test_dataset.py:4956: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
xarray/coding/cftime_offsets.py:955: in cftime_range
    start = to_cftime_datetime(start, calendar)
xarray/coding/cftime_offsets.py:678: in to_cftime_datetime
    date, _ = _parse_iso8601_with_reso(get_date_type(calendar),
xarray/coding/cftimeindex.py:114: in _parse_iso8601_with_reso
    return default.replace(**replace), resolution
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

>   ???
E   ValueError: Replacing the dayofyr or dayofwk of a datetime is not supported.

src/cftime/_cftime.pyx:1315: ValueError
_______________________ test_differentiate_cftime[True] ________________________

dask = True

    @pytest.mark.skipif(not has_cftime, reason='Test requires cftime.')
    @pytest.mark.parametrize('dask', [True, False])
    def test_differentiate_cftime(dask):
        rs = np.random.RandomState(42)
>       coord = xr.cftime_range('2000', periods=8, freq='2M')

xarray/tests/test_dataset.py:5173: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
xarray/coding/cftime_offsets.py:955: in cftime_range
    start = to_cftime_datetime(start, calendar)
xarray/coding/cftime_offsets.py:678: in to_cftime_datetime
    date, _ = _parse_iso8601_with_reso(get_date_type(calendar),
xarray/coding/cftimeindex.py:114: in _parse_iso8601_with_reso
    return default.replace(**replace), resolution
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

>   ???
E   ValueError: Replacing the dayofyr or dayofwk of a datetime is not supported.

src/cftime/_cftime.pyx:1315: ValueError
_______________________ test_differentiate_cftime[False] _______________________

dask = False

    @pytest.mark.skipif(not has_cftime, reason='Test requires cftime.')
    @pytest.mark.parametrize('dask', [True, False])
    def test_differentiate_cftime(dask):
        rs = np.random.RandomState(42)
>       coord = xr.cftime_range('2000', periods=8, freq='2M')

xarray/tests/test_dataset.py:5173: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
xarray/coding/cftime_offsets.py:955: in cftime_range
    start = to_cftime_datetime(start, calendar)
xarray/coding/cftime_offsets.py:678: in to_cftime_datetime
    date, _ = _parse_iso8601_with_reso(get_date_type(calendar),
xarray/coding/cftimeindex.py:114: in _parse_iso8601_with_reso
    return default.replace(**replace), resolution
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

>   ???
E   ValueError: Replacing the dayofyr or dayofwk of a datetime is not supported.

src/cftime/_cftime.pyx:1315: ValueError
_______________________ test_trapz_datetime[cftime-True] _______________________

dask = True, which_datetime = 'cftime'

    @pytest.mark.parametrize('dask', [True, False])
    @pytest.mark.parametrize('which_datetime', ['np', 'cftime'])
    def test_trapz_datetime(dask, which_datetime):
        rs = np.random.RandomState(42)
        if which_datetime == 'np':
            coord = np.array(
                ['2004-07-13', '2006-01-13', '2010-08-13', '2010-09-13',
                 '2010-10-11', '2010-12-13', '2011-02-13', '2012-08-13'],
                dtype='datetime64')
        else:
            if not has_cftime:
                pytest.skip('Test requires cftime.')
>           coord = xr.cftime_range('2000', periods=8, freq='2D')

xarray/tests/test_dataset.py:5252: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
xarray/coding/cftime_offsets.py:955: in cftime_range
    start = to_cftime_datetime(start, calendar)
xarray/coding/cftime_offsets.py:678: in to_cftime_datetime
    date, _ = _parse_iso8601_with_reso(get_date_type(calendar),
xarray/coding/cftimeindex.py:114: in _parse_iso8601_with_reso
    return default.replace(**replace), resolution
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

>   ???
E   ValueError: Replacing the dayofyr or dayofwk of a datetime is not supported.

src/cftime/_cftime.pyx:1315: ValueError
______________________ test_trapz_datetime[cftime-False] _______________________

dask = False, which_datetime = 'cftime'

    @pytest.mark.parametrize('dask', [True, False])
    @pytest.mark.parametrize('which_datetime', ['np', 'cftime'])
    def test_trapz_datetime(dask, which_datetime):
        rs = np.random.RandomState(42)
        if which_datetime == 'np':
            coord = np.array(
                ['2004-07-13', '2006-01-13', '2010-08-13', '2010-09-13',
                 '2010-10-11', '2010-12-13', '2011-02-13', '2012-08-13'],
                dtype='datetime64')
        else:
            if not has_cftime:
                pytest.skip('Test requires cftime.')
>           coord = xr.cftime_range('2000', periods=8, freq='2D')

xarray/tests/test_dataset.py:5252: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
xarray/coding/cftime_offsets.py:955: in cftime_range
    start = to_cftime_datetime(start, calendar)
xarray/coding/cftime_offsets.py:678: in to_cftime_datetime
    date, _ = _parse_iso8601_with_reso(get_date_type(calendar),
xarray/coding/cftimeindex.py:114: in _parse_iso8601_with_reso
    return default.replace(**replace), resolution
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

>   ???
E   ValueError: Replacing the dayofyr or dayofwk of a datetime is not supported.

src/cftime/_cftime.pyx:1315: ValueError
=============================== warnings summary ===============================
xarray/core/dask_array_ops.py:11
xarray/core/dask_array_ops.py:11
  /testbed/xarray/core/dask_array_ops.py:11: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(dask.__version__) <= LooseVersion('0.18.2'):

xarray/core/npcompat.py:135
xarray/core/npcompat.py:135
  /testbed/xarray/core/npcompat.py:135: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(np.__version__) >= LooseVersion('1.13'):

xarray/core/dask_array_compat.py:43
xarray/core/dask_array_compat.py:43
  /testbed/xarray/core/dask_array_compat.py:43: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(dask_version) > LooseVersion('0.19.2'):

xarray/plot/utils.py:17
xarray/plot/utils.py:17
  /testbed/xarray/plot/utils.py:17: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(nc_time_axis.__version__) < LooseVersion('1.2.0'):

xarray/core/pdcompat.py:46
  /testbed/xarray/core/pdcompat.py:46: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(pd.__version__) < '0.25.0':

../opt/miniconda3/envs/testbed/lib/python3.10/site-packages/setuptools/_distutils/version.py:345: 2 warnings
xarray/tests/test_variable.py: 101 warnings
xarray/tests/test_dataarray.py: 78 warnings
xarray/tests/test_dataset.py: 53 warnings
  /opt/miniconda3/envs/testbed/lib/python3.10/site-packages/setuptools/_distutils/version.py:345: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    other = LooseVersion(other)

xarray/tests/__init__.py:57: 17 warnings
xarray/tests/test_dataarray.py: 2 warnings
xarray/tests/test_dataset.py: 1 warning
  /testbed/xarray/tests/__init__.py:57: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    return version.LooseVersion(vstring)

xarray/tests/test_variable.py: 12 warnings
xarray/tests/test_dataarray.py: 12 warnings
xarray/tests/test_dataset.py: 63 warnings
  /testbed/xarray/core/variable.py:1596: DeprecationWarning: the `interpolation=` argument to nanpercentile was renamed to `method=`, which has additional options.
  Users of the modes 'nearest', 'lower', 'higher', or 'midpoint' are encouraged to review the method they used. (Deprecated NumPy 1.22)
    qs = np.nanpercentile(self.data, q * 100., axis=axis,

xarray/tests/test_variable.py: 99 warnings
xarray/tests/test_dataarray.py: 61 warnings
xarray/tests/test_dataset.py: 45 warnings
  /testbed/xarray/core/variable.py:900: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(dask.__version__) > '1.2.2':

xarray/tests/test_variable.py::TestVariableWithDask::test_eq_all_dtypes
  /opt/miniconda3/envs/testbed/lib/python3.10/site-packages/dask/core.py:119: FutureWarning: elementwise comparison failed; returning scalar instead, but in the future will perform elementwise comparison
    return func(*(_execute_task(a, cache) for a in args))

xarray/tests/test_variable.py::TestVariableWithDask::test_equals_all_dtypes
  /testbed/xarray/tests/test_variable.py:1810: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if '0.18.2' <= LooseVersion(dask.__version__) < '0.19.1':

xarray/tests/test_variable.py::test_raise_no_warning_for_nan_in_binary_ops
xarray/tests/test_dataarray.py::test_raise_no_warning_for_nan_in_binary_ops
xarray/tests/test_dataset.py::TestDataset::test_reindex_warning
xarray/tests/test_dataset.py::test_raise_no_warning_for_nan_in_binary_ops
  /opt/miniconda3/envs/testbed/lib/python3.10/site-packages/_pytest/python.py:194: PytestRemovedIn8Warning: Passing None has been deprecated.
  See https://docs.pytest.org/en/latest/how-to/capture-warnings.html#additional-use-cases-of-warnings-in-tests for alternatives in common use cases.
    result = testfunction(**testargs)

xarray/tests/test_dataarray.py: 77 warnings
xarray/tests/test_dataset.py: 404 warnings
  /testbed/xarray/core/formatting.py:147: DeprecationWarning: `np.float` is a deprecated alias for the builtin `float`. To silence this warning, use `float` by itself. Doing this will not modify any behavior and is safe. If you specifically wanted the numpy scalar type, use `np.float64` here.
  Deprecated in NumPy 1.20; for more details and guidance: https://numpy.org/devdocs/release/1.20.0-notes.html#deprecations
    elif isinstance(x, (float, np.float)):

xarray/tests/test_dataarray.py: 5 warnings
xarray/tests/test_dataset.py: 6 warnings
  /testbed/xarray/core/alignment.py:138: FutureWarning: Index.__and__ operating as a set operation is deprecated, in the future this will be a logical operation matching Series.__and__.  Use index.intersection(other) instead.
    index = joiner(matching_indexes)

xarray/tests/test_dataarray.py: 34 warnings
xarray/tests/test_dataset.py: 30 warnings
  /testbed/xarray/core/dataset.py:2897: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(pd.__version__) < LooseVersion('0.19.0'):

xarray/tests/test_dataarray.py: 10 warnings
xarray/tests/test_dataset.py: 7 warnings
  /testbed/xarray/core/dataset.py:3073: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(pd.__version__) >= "0.20":

xarray/tests/test_dataarray.py: 14 warnings
xarray/tests/test_dataset.py: 19 warnings
  /testbed/xarray/core/alignment.py:138: FutureWarning: Index.__or__ operating as a set operation is deprecated, in the future this will be a logical operation matching Series.__or__.  Use index.union(other) instead.
    index = joiner(matching_indexes)

xarray/tests/test_dataarray.py::TestDataArray::test_reindex_regressions
  /testbed/xarray/tests/test_dataarray.py:1306: DeprecationWarning: `np.complex` is a deprecated alias for the builtin `complex`. To silence this warning, use `complex` by itself. Doing this will not modify any behavior and is safe. If you specifically wanted the numpy scalar type, use `np.complex128` here.
  Deprecated in NumPy 1.20; for more details and guidance: https://numpy.org/devdocs/release/1.20.0-notes.html#deprecations
    x = np.array([1, 2, 3], dtype=np.complex)

xarray/tests/test_dataarray.py::TestDataArray::test_stack_unstack
  /testbed/xarray/tests/test_dataarray.py:1792: FutureWarning: pandas.Int64Index is deprecated and will be removed from pandas in a future version. Use pandas.Index with the appropriate dtype instead.
    b = pd.MultiIndex(levels=[pd.Int64Index([]), pd.Int64Index([0])],

xarray/tests/test_dataarray.py::TestDataArray::test_stack_unstack
  /opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/util/__init__.py:16: FutureWarning: pandas.util.testing is deprecated. Use the functions in the public API at pandas.testing instead.
    import pandas.util.testing

xarray/tests/test_dataarray.py: 9 warnings
xarray/tests/test_dataset.py: 5 warnings
  /testbed/xarray/core/groupby.py:153: FutureWarning: is_monotonic is deprecated and will be removed in a future version. Use is_monotonic_increasing instead.
    return index.is_unique and index.is_monotonic

xarray/tests/test_dataarray.py::TestDataArray::test_groupby_bins_sort
  /testbed/xarray/tests/test_dataarray.py:2483: FutureWarning: is_monotonic is deprecated and will be removed in a future version. Use is_monotonic_increasing instead.
    assert binned_mean.to_index().is_monotonic

xarray/tests/test_dataarray.py: 41 warnings
xarray/tests/test_dataset.py: 10 warnings
  /testbed/xarray/core/common.py:840: FutureWarning: 'base' in .resample() and in Grouper() is deprecated.
  The new arguments that you should use are 'offset' or 'origin'.
  
  >>> df.resample(freq="3s", base=2)
  
  becomes:
  
  >>> df.resample(freq="3s", offset="2s")
  
    grouper = pd.Grouper(freq=freq, closed=closed, label=label,

xarray/tests/test_dataarray.py: 40 warnings
xarray/tests/test_dataset.py: 10 warnings
  /testbed/xarray/core/groupby.py:264: FutureWarning: is_monotonic is deprecated and will be removed in a future version. Use is_monotonic_increasing instead.
    if not index.is_monotonic:

xarray/tests/test_dataarray.py::TestDataArray::test_resample
xarray/tests/test_dataset.py::TestDataset::test_resample_loffset
  /testbed/xarray/core/common.py:840: FutureWarning: 'loffset' in .resample() and in Grouper() is deprecated.
  
  >>> df.resample(freq="3s", loffset="8H")
  
  becomes:
  
  >>> from pandas.tseries.frequencies import to_offset
  >>> df = df.resample(freq="3s").mean()
  >>> df.index = df.index.to_timestamp() + to_offset("8H")
  
    grouper = pd.Grouper(freq=freq, closed=closed, label=label,

xarray/tests/test_dataarray.py::TestDataArray::test_resample
  /testbed/xarray/tests/test_dataarray.py:2497: FutureWarning: 'loffset' in .resample() and in Grouper() is deprecated.
  
  >>> df.resample(freq="3s", loffset="8H")
  
  becomes:
  
  >>> from pandas.tseries.frequencies import to_offset
  >>> df = df.resample(freq="3s").mean()
  >>> df.index = df.index.to_timestamp() + to_offset("8H")
  
    expected = DataArray(array.to_series().resample('24H', loffset='-12H')

xarray/tests/test_dataarray.py::TestDataArray::test_resample_drop_nondim_coords
xarray/tests/test_dataarray.py::TestDataArray::test_upsample_interpolate
xarray/tests/test_dataarray.py::TestDataArray::test_upsample_interpolate
xarray/tests/test_dataarray.py::TestDataArray::test_upsample_interpolate_bug_2197
xarray/tests/test_dataarray.py::TestDataArray::test_upsample_interpolate_regression_1605
xarray/tests/test_dataarray.py::TestDataArray::test_upsample_interpolate_dask
xarray/tests/test_dataarray.py::TestDataArray::test_upsample_interpolate_dask
xarray/tests/test_dataarray.py::TestDataArray::test_upsample_interpolate_dask
xarray/tests/test_dataset.py::TestDataset::test_resample_drop_nondim_coords
  /testbed/xarray/core/missing.py:380: FutureWarning: Passing method to DatetimeIndex.get_loc is deprecated and will raise in a future version. Use index.get_indexer([item], method=...) instead.
    imin = index.get_loc(np.min(new_x.values), method='nearest')

xarray/tests/test_dataarray.py::TestDataArray::test_resample_drop_nondim_coords
xarray/tests/test_dataarray.py::TestDataArray::test_upsample_interpolate
xarray/tests/test_dataarray.py::TestDataArray::test_upsample_interpolate
xarray/tests/test_dataarray.py::TestDataArray::test_upsample_interpolate_bug_2197
xarray/tests/test_dataarray.py::TestDataArray::test_upsample_interpolate_regression_1605
xarray/tests/test_dataarray.py::TestDataArray::test_upsample_interpolate_dask
xarray/tests/test_dataarray.py::TestDataArray::test_upsample_interpolate_dask
xarray/tests/test_dataarray.py::TestDataArray::test_upsample_interpolate_dask
xarray/tests/test_dataset.py::TestDataset::test_resample_drop_nondim_coords
  /testbed/xarray/core/missing.py:381: FutureWarning: Passing method to DatetimeIndex.get_loc is deprecated and will raise in a future version. Use index.get_indexer([item], method=...) instead.
    imax = index.get_loc(np.max(new_x.values), method='nearest')

xarray/tests/test_dataarray.py::TestDataArray::test_upsample
  /testbed/xarray/tests/test_dataarray.py:2630: FutureWarning: pad is deprecated and will be removed in a future version. Use ffill instead.
    expected = DataArray(array.to_series().resample('3H').pad())

xarray/tests/test_dataarray.py::TestDataArray::test_to_and_from_empty_series
  /testbed/xarray/tests/test_dataarray.py:3083: FutureWarning: The default dtype for empty Series will be 'object' instead of 'float64' in a future version. Specify a dtype explicitly to silence this warning.
    expected = pd.Series([])

xarray/tests/test_dataarray.py::TestDataArray::test_to_and_from_cdms2_classic
xarray/tests/test_dataarray.py::TestIrisConversion::test_to_and_from_iris
xarray/tests/test_dataarray.py::TestIrisConversion::test_to_and_from_iris
xarray/tests/test_dataarray.py::TestIrisConversion::test_to_and_from_iris_dask
xarray/tests/test_dataarray.py::TestIrisConversion::test_to_and_from_iris_dask
  /testbed/xarray/coding/times.py:212: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(pd.__version__) < '0.25.0':

xarray/tests/test_dataarray.py::TestDataArray::test_to_and_from_cdms2_sgrid
xarray/tests/test_dataarray.py::TestDataArray::test_to_and_from_cdms2_sgrid
xarray/tests/test_dataarray.py::TestDataArray::test_to_and_from_cdms2_sgrid
xarray/tests/test_dataarray.py::TestDataArray::test_to_and_from_cdms2_sgrid
  /opt/miniconda3/envs/testbed/lib/python3.10/site-packages/numpy/ma/core.py:7939: DeprecationWarning: elementwise comparison failed; this will raise an error in the future.
    if not np.all(xinf == filled(np.isinf(y), False)):

xarray/tests/test_dataarray.py: 1952 warnings
xarray/tests/test_dataset.py: 5320 warnings
  /testbed/xarray/core/rolling.py:75: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    (LooseVersion(bottleneck.__version__) < LooseVersion('1.0'))):

xarray/tests/test_dataarray.py: 386 warnings
xarray/tests/test_dataset.py: 1016 warnings
  /testbed/xarray/core/rolling.py:322: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if (LooseVersion(np.__version__) < LooseVersion('1.13') and

xarray/tests/test_dataset.py::TestDataset::test_constructor_pandas_single
  /testbed/xarray/core/merge.py:321: FutureWarning: iteritems is deprecated and will be removed in a future version. Use .items instead.
    obj = OrderedDict(obj.iteritems())

xarray/tests/test_dataset.py::TestDataset::test_sel_method
xarray/tests/test_dataset.py::TestDataset::test_sel_method
xarray/tests/test_dataset.py::TestDataset::test_sel_method
  /testbed/xarray/core/indexing.py:108: FutureWarning: Passing method to Float64Index.get_loc is deprecated and will raise in a future version. Use index.get_indexer([item], method=...) instead.
    return index.get_loc(label, **kwargs)

xarray/tests/test_dataset.py::TestDataset::test_resample_loffset
  /testbed/xarray/tests/test_dataset.py:3226: FutureWarning: 'loffset' in .resample() and in Grouper() is deprecated.
  
  >>> df.resample(freq="3s", loffset="8H")
  
  becomes:
  
  >>> from pandas.tseries.frequencies import to_offset
  >>> df = df.resample(freq="3s").mean()
  >>> df.index = df.index.to_timestamp() + to_offset("8H")
  
    expected = xr.DataArray(ds.bar.to_series()

xarray/tests/test_dataset.py::TestDataset::test_sortby
xarray/tests/test_dataset.py::TestDataset::test_sortby
xarray/tests/test_dataset.py::TestDataset::test_sortby
xarray/tests/test_dataset.py::TestDataset::test_sortby
xarray/tests/test_dataset.py::TestDataset::test_sortby
xarray/tests/test_dataset.py::TestDataset::test_sortby
xarray/tests/test_dataset.py::TestDataset::test_sortby
xarray/tests/test_dataset.py::TestDataset::test_sortby
  /testbed/xarray/core/dataset.py:4390: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    and LooseVersion(np.__version__) < LooseVersion('1.11.0')):

xarray/tests/test_dataset.py::test_coarsen_coords[1-True]
xarray/tests/test_dataset.py::test_coarsen_coords[1-False]
  /testbed/xarray/tests/test_dataset.py:4950: UserWarning: Parsing dates in DD/MM/YYYY format when dayfirst=False (the default) was specified. This may lead to inconsistently parsed dates! Specify a format to ensure consistent parsing.
    coords={'time': pd.date_range('15/12/1999', periods=364)})

-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
=========================== short test summary info ============================
FAILED xarray/tests/test_dataset.py::TestDataset::test_expand_dims_error - As...
FAILED xarray/tests/test_dataset.py::TestDataset::test_expand_dims_kwargs_python36plus
FAILED xarray/tests/test_dataset.py::test_coarsen_coords_cftime - ValueError:...
FAILED xarray/tests/test_dataset.py::test_differentiate_cftime[True] - ValueE...
FAILED xarray/tests/test_dataset.py::test_differentiate_cftime[False] - Value...
FAILED xarray/tests/test_dataset.py::test_trapz_datetime[cftime-True] - Value...
FAILED xarray/tests/test_dataset.py::test_trapz_datetime[cftime-False] - Valu...
7 failed, 1729 passed, 19 skipped, 11 xfailed, 4 xpassed, 10007 warnings in 30.97s

the Check fails on the tree as the run found it too (baseline-check.log), and this change adds no failing test to it: it passes
scope: xarray/core/indexing.py xarray/core/variable.py xarray/tests/test_variable.py xarray/tests/test_dataarray.py xarray/tests/test_dataset.py
changed: xarray/core/variable.py +2 -1
changed: xarray/tests/test_dataarray.py +11 -1
changed: xarray/tests/test_dataset.py +10 -0
changed: xarray/tests/test_variable.py +8 -0
```

### `direct-status.txt`

```
0
```

### `direct.patch`

```diff
diff --git a/xarray/core/variable.py b/xarray/core/variable.py
index 379be8f5..4dc056af 100644
--- a/xarray/core/variable.py
+++ b/xarray/core/variable.py
@@ -1947,7 +1947,8 @@ class IndexVariable(Variable):
                 # point, which doesn't have a copy method, so make a deep copy
                 # of the underlying `pandas.MultiIndex` and create a new
                 # `PandasIndexAdapter` instance with it.
-                data = PandasIndexAdapter(self._data.array.copy(deep=True))
+                data = PandasIndexAdapter(self._data.array.copy(deep=True),
+                                          dtype=self._data.dtype)
             else:
                 data = self._data
         else:
diff --git a/xarray/tests/test_dataarray.py b/xarray/tests/test_dataarray.py
index 5697704b..989ba556 100644
--- a/xarray/tests/test_dataarray.py
+++ b/xarray/tests/test_dataarray.py
@@ -2,7 +2,7 @@ import pickle
 import sys
 import warnings
 from collections import OrderedDict
-from copy import deepcopy
+from copy import copy, deepcopy
 from textwrap import dedent
 
 import numpy as np
@@ -3454,6 +3454,16 @@ class TestDataArray:
         expected.data = new_data
         assert_identical(expected, actual)
 
+    def test_copy_unicode_index_dtype(self):
+        # regression test: copying should not cast unicode indices to object
+        da = DataArray(
+            ['baz'], dims='x',
+            coords={'x': ['foo'], 'y': ('x', ['bar'])})
+        for copied in [da.copy(deep=True), da.copy(deep=False),
+                       copy(da), deepcopy(da)]:
+            assert copied['x'].dtype == da['x'].dtype
+            assert_identical(da, copied)
+
     @pytest.mark.xfail(raises=AssertionError)
     @pytest.mark.parametrize('deep, expected_orig', [
         [True,
diff --git a/xarray/tests/test_dataset.py b/xarray/tests/test_dataset.py
index fc6f7f36..31ac6568 100644
--- a/xarray/tests/test_dataset.py
+++ b/xarray/tests/test_dataset.py
@@ -2069,6 +2069,16 @@ class TestDataset:
 
             assert data.attrs['Test'] is not copied.attrs['Test']
 
+    def test_copy_unicode_index_dtype(self):
+        # regression test: copying should not cast unicode indices to object
+        ds = Dataset(
+            coords={'x': ['foo'], 'y': ('x', ['bar'])},
+            data_vars={'z': ('x', ['baz'])})
+        for copied in [ds.copy(deep=True), ds.copy(deep=False),
+                       copy(ds), deepcopy(ds)]:
+            assert copied['x'].dtype == ds['x'].dtype
+            assert_identical(ds, copied)
+
     def test_copy_with_data(self):
         orig = create_test_data()
         new_data = {k: np.random.randn(*v.shape)
diff --git a/xarray/tests/test_variable.py b/xarray/tests/test_variable.py
index 73d2a40b..ae2bfa0a 100644
--- a/xarray/tests/test_variable.py
+++ b/xarray/tests/test_variable.py
@@ -502,6 +502,14 @@ class VariableSubclassobjects:
             assert isinstance(w.to_index(), pd.MultiIndex)
             assert_array_equal(v._data.array, w._data.array)
 
+    def test_copy_index_unicode_dtype(self):
+        # regression test for GH: unicode indices were cast to object
+        v = self.cls('x', np.array(['foo', 'bar'], dtype='<U3'))
+        for deep in [True, False]:
+            w = v.copy(deep=deep)
+            assert w.dtype == v.dtype
+            assert_identical(v, w)
+
     def test_copy_with_data(self):
         orig = Variable(('x', 'y'), [[1.5, 2.0], [3.1, 4.3]], {'foo': 'bar'})
         new_data = np.array([[2.5, 5.0], [7.1, 43]])
```

### `done.sh`

```
#!/usr/bin/env bash
# done.sh <step> <run dir>: whether an agent step did its part, the step's
# target. Exit 0 when it did; otherwise exit 1 and say what is missing. The
# problem step copies it into the run's folder; a task cannot edit its own
# target (gateway/target_guard.go).
set -u
step="$1"; r="$2"; miss=0
w=.memdoor/workflows/team-solve; [ -d "$w" ] || w="$HOME/.memdoor/workflows/team-solve"
no() { printf 'not done: %s\n' "$1"; miss=1; }
# section <file> <heading>: the lines under "## <heading>", comments and blanks dropped.
section() { sed -n "/^## $2\$/,/^## /p" "$1" | sed '1d;/^## /d;/^<!--.*-->$/d;/^[[:space:]]*$/d'; }
verdict() { [ -s "$1" ] && head -1 "$1" | grep -qE '^verdict: (PASS|FAIL)$'; }

case "$step" in
plan)
  t="$r/task.md"
  for s in Deliverable Check Scope "Done when"; do
    [ -n "$(section "$t" "$s")" ] || no "task.md: the $s section is not filled in"
  done
  { section "$t" Check | grep -q '`[^`]*`' || section "$t" Check | grep -qwE 'samples|judge'; } \
    || no 'task.md: Check names no command in backticks, nor samples, nor judge'
  section "$t" Scope | grep -q '`[^`]*`' || no 'task.md: Scope names no file or directory in backticks'
  first=$(grep -m1 '[^[:space:]]' "$r/prompt.md")
  grep -qF -- "$first" "$t" || no 'task.md: the Prompt section was changed; put it back as prompt.md has it'
  grep -q '[^[:space:]]' "$r/plan.md" 2>/dev/null || no 'plan.md is missing or empty'
  [ -f "$r/notes.md" ] || no 'notes.md is missing' ;;
solve)
  bash "$w/changes.sh" "$r" > /dev/null
  [ -s "$r/changes.diff" ] || no 'nothing in the project changed yet: do the task as the Deliverable says' ;;
review)
  verdict "$r/review.md" || no 'review.md: its first line must be `verdict: PASS` or `verdict: FAIL`' ;;
repair)
  head -1 "$r/review.md" 2>/dev/null | grep -qx 'verdict: PASS' && exit 0
  grep -q '[^[:space:]]' "$r/repair.md" 2>/dev/null || no 'repair.md is missing: what you changed and what the Check printed' ;;
judge)
  verdict "$r/verdict.md" || no 'verdict.md: its first line must be `verdict: PASS` or `verdict: FAIL`' ;;
*) echo "done.sh: unknown step $step"; exit 2 ;;
esac
[ "$miss" = 0 ] && printf '%s: done\n' "$step"
exit "$miss"
```

### `final-check.log`

```
check: pytest xarray/tests/test_variable.py xarray/tests/test_dataarray.py xarray/tests/test_dataset.py -q
........................................................................ [  4%]
........................................................................ [  8%]
....................xxxx................................................ [ 12%]
..................xxxxxxx............................................... [ 16%]
........................................................................ [ 20%]
................s.s..................................................... [ 24%]
......................XX................................................ [ 28%]
........................................................................ [ 32%]
........................................................................ [ 36%]
........................................................................ [ 40%]
........................................................................ [ 44%]
........................................................................ [ 48%]
........................................................................ [ 52%]
...............................................................XX....... [ 56%]
.F.....sF............................................................... [ 61%]
........................................................................ [ 65%]
............................F........................................... [ 69%]
........................................................................ [ 73%]
........................................................................ [ 77%]
...................................................................sssss [ 81%]
sssssssssss............................................................. [ 85%]
........................................................................ [ 89%]
........................................................................ [ 93%]
........................................................................ [ 97%]
..................................FF....FF                               [100%]
=================================== FAILURES ===================================
______________________ TestDataset.test_expand_dims_error ______________________

self = <xarray.tests.test_dataset.TestDataset object at 0x7c2ff068fe50>

    def test_expand_dims_error(self):
        original = Dataset({'x': ('a', np.random.randn(3)),
                            'y': (['b', 'a'], np.random.randn(4, 3)),
                            'z': ('a', np.random.randn(3))},
                           coords={'a': np.linspace(0, 1, 3),
                                   'b': np.linspace(0, 1, 4),
                                   'c': np.linspace(0, 1, 5)},
                           attrs={'key': 'entry'})
    
        with raises_regex(ValueError, 'already exists'):
            original.expand_dims(dim=['x'])
    
        # Make sure it raises true error also for non-dimensional coordinates
        # which has dimension.
        original = original.set_coords('z')
        with raises_regex(ValueError, 'already exists'):
            original.expand_dims(dim=['z'])
    
        original = Dataset({'x': ('a', np.random.randn(3)),
                            'y': (['b', 'a'], np.random.randn(4, 3)),
                            'z': ('a', np.random.randn(3))},
                           coords={'a': np.linspace(0, 1, 3),
                                   'b': np.linspace(0, 1, 4),
                                   'c': np.linspace(0, 1, 5)},
                           attrs={'key': 'entry'})
        with raises_regex(TypeError, 'value of new dimension'):
            original.expand_dims(OrderedDict((("d", 3.2),)))
    
        # TODO: only the code under the if-statement is needed when python 3.5
        #   is no longer supported.
        python36_plus = sys.version_info[0] == 3 and sys.version_info[1] > 5
        if python36_plus:
            with raises_regex(ValueError, 'both keyword and positional'):
>               original.expand_dims(OrderedDict((("d", 4),)), e=4)

xarray/tests/test_dataset.py:2283: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <xarray.Dataset>
Dimensions:  (a: 3, b: 4, c: 5)
Coordinates:
  * a        (a) float64 0.0 0.5 1.0
  * b        (b) fl... -0.08491 0.4119 ... -0.33 -0.8308 -0.6308
    z        (a) float64 0.6191 -1.519 1.003
Attributes:
    key:      entry
dim = OrderedDict([('d', 4)]), axis = None, dim_kwargs = {'e': 4}

    def expand_dims(
        self,
        dim: Union[None, Hashable, Sequence[Hashable],
                   Mapping[Hashable, Any]] = None,
        axis: Union[None, int, Sequence[int]] = None,
        **dim_kwargs: Any
    ) -> 'Dataset':
        """Return a new object with an additional axis (or axes) inserted at
        the corresponding position in the array shape.  The new object is a
        view into the underlying array, not a copy.
    
        If dim is already a scalar coordinate, it will be promoted to a 1D
        coordinate consisting of a single value.
    
        Parameters
        ----------
        dim : hashable, sequence of hashable, mapping, or None
            Dimensions to include on the new variable. If provided as hashable
            or sequence of hashable, then dimensions are inserted with length
            1. If provided as a mapping, then the keys are the new dimensions
            and the values are either integers (giving the length of the new
            dimensions) or array-like (giving the coordinates of the new
            dimensions).
    
            .. note::
    
               For Python 3.5, if ``dim`` is a mapping, then it must be an
               ``OrderedDict``. This is to ensure that the order in which the
               dims are given is maintained.
    
        axis : integer, sequence of integers, or None
            Axis position(s) where new axis is to be inserted (position(s) on
            the result array). If a list (or tuple) of integers is passed,
            multiple axes are inserted. In this case, dim arguments should be
            same length list. If axis=None is passed, all the axes will be
            inserted to the start of the result array.
        **dim_kwargs : int or sequence/ndarray
            The keywords are arbitrary dimensions being inserted and the values
            are either the lengths of the new dims (if int is given), or their
            coordinates. Note, this is an alternative to passing a dict to the
            dim kwarg and will only be used if dim is None.
    
            .. note::
    
               For Python 3.5, ``dim_kwargs`` is not available.
    
        Returns
        -------
        expanded : same type as caller
            This object, but with an additional dimension(s).
        """
        # TODO: get rid of the below code block when python 3.5 is no longer
        #   supported.
        if sys.version < '3.6':
            if isinstance(dim, Mapping) and not isinstance(dim, OrderedDict):
                raise TypeError("dim must be an OrderedDict for python <3.6")
            if dim_kwargs:
>               raise ValueError("dim_kwargs isn't available for python <3.6")
E               ValueError: dim_kwargs isn't available for python <3.6

xarray/core/dataset.py:2659: ValueError

During handling of the above exception, another exception occurred:

self = <xarray.tests.test_dataset.TestDataset object at 0x7c2ff068fe50>

    def test_expand_dims_error(self):
        original = Dataset({'x': ('a', np.random.randn(3)),
                            'y': (['b', 'a'], np.random.randn(4, 3)),
                            'z': ('a', np.random.randn(3))},
                           coords={'a': np.linspace(0, 1, 3),
                                   'b': np.linspace(0, 1, 4),
                                   'c': np.linspace(0, 1, 5)},
                           attrs={'key': 'entry'})
    
        with raises_regex(ValueError, 'already exists'):
            original.expand_dims(dim=['x'])
    
        # Make sure it raises true error also for non-dimensional coordinates
        # which has dimension.
        original = original.set_coords('z')
        with raises_regex(ValueError, 'already exists'):
            original.expand_dims(dim=['z'])
    
        original = Dataset({'x': ('a', np.random.randn(3)),
                            'y': (['b', 'a'], np.random.randn(4, 3)),
                            'z': ('a', np.random.randn(3))},
                           coords={'a': np.linspace(0, 1, 3),
                                   'b': np.linspace(0, 1, 4),
                                   'c': np.linspace(0, 1, 5)},
                           attrs={'key': 'entry'})
        with raises_regex(TypeError, 'value of new dimension'):
            original.expand_dims(OrderedDict((("d", 3.2),)))
    
        # TODO: only the code under the if-statement is needed when python 3.5
        #   is no longer supported.
        python36_plus = sys.version_info[0] == 3 and sys.version_info[1] > 5
        if python36_plus:
>           with raises_regex(ValueError, 'both keyword and positional'):

xarray/tests/test_dataset.py:2282: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <contextlib._GeneratorContextManager object at 0x7c2fe6acc1c0>
typ = <class 'ValueError'>
value = ValueError("dim_kwargs isn't available for python <3.6")
traceback = <traceback object at 0x7c2fe6ad0a40>

    def __exit__(self, typ, value, traceback):
        if typ is None:
            try:
                next(self.gen)
            except StopIteration:
                return False
            else:
                raise RuntimeError("generator didn't stop")
        else:
            if value is None:
                # Need to force instantiation so we can reliably
                # tell if we get the same exception back
                value = typ()
            try:
>               self.gen.throw(typ, value, traceback)
E               AssertionError: exception ValueError("dim_kwargs isn't available for python <3.6") did not match pattern 'both keyword and positional'

/opt/miniconda3/envs/testbed/lib/python3.10/contextlib.py:153: AssertionError
_______________ TestDataset.test_expand_dims_kwargs_python36plus _______________

self = <xarray.tests.test_dataset.TestDataset object at 0x7c2ff06bc670>

    @pytest.mark.skipif(
        sys.version_info[:2] < (3, 6),
        reason='keyword arguments are only ordered on Python 3.6+',
    )
    def test_expand_dims_kwargs_python36plus(self):
        original = Dataset({'x': ('a', np.random.randn(3)),
                            'y': (['b', 'a'], np.random.randn(4, 3))},
                           coords={'a': np.linspace(0, 1, 3),
                                   'b': np.linspace(0, 1, 4),
                                   'c': np.linspace(0, 1, 5)},
                           attrs={'key': 'entry'})
>       other_way = original.expand_dims(e=["l", "m", "n"])

xarray/tests/test_dataset.py:2389: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <xarray.Dataset>
Dimensions:  (a: 3, b: 4, c: 5)
Coordinates:
  * a        (a) float64 0.0 0.5 1.0
  * b        (b) fl...0.4995
    y        (b, a) float64 0.5561 -0.6058 -2.091 1.239 ... 1.936 -1.177 0.01932
Attributes:
    key:      entry
dim = None, axis = None, dim_kwargs = {'e': ['l', 'm', 'n']}

    def expand_dims(
        self,
        dim: Union[None, Hashable, Sequence[Hashable],
                   Mapping[Hashable, Any]] = None,
        axis: Union[None, int, Sequence[int]] = None,
        **dim_kwargs: Any
    ) -> 'Dataset':
        """Return a new object with an additional axis (or axes) inserted at
        the corresponding position in the array shape.  The new object is a
        view into the underlying array, not a copy.
    
        If dim is already a scalar coordinate, it will be promoted to a 1D
        coordinate consisting of a single value.
    
        Parameters
        ----------
        dim : hashable, sequence of hashable, mapping, or None
            Dimensions to include on the new variable. If provided as hashable
            or sequence of hashable, then dimensions are inserted with length
            1. If provided as a mapping, then the keys are the new dimensions
            and the values are either integers (giving the length of the new
            dimensions) or array-like (giving the coordinates of the new
            dimensions).
    
            .. note::
    
               For Python 3.5, if ``dim`` is a mapping, then it must be an
               ``OrderedDict``. This is to ensure that the order in which the
               dims are given is maintained.
    
        axis : integer, sequence of integers, or None
            Axis position(s) where new axis is to be inserted (position(s) on
            the result array). If a list (or tuple) of integers is passed,
            multiple axes are inserted. In this case, dim arguments should be
            same length list. If axis=None is passed, all the axes will be
            inserted to the start of the result array.
        **dim_kwargs : int or sequence/ndarray
            The keywords are arbitrary dimensions being inserted and the values
            are either the lengths of the new dims (if int is given), or their
            coordinates. Note, this is an alternative to passing a dict to the
            dim kwarg and will only be used if dim is None.
    
            .. note::
    
               For Python 3.5, ``dim_kwargs`` is not available.
    
        Returns
        -------
        expanded : same type as caller
            This object, but with an additional dimension(s).
        """
        # TODO: get rid of the below code block when python 3.5 is no longer
        #   supported.
        if sys.version < '3.6':
            if isinstance(dim, Mapping) and not isinstance(dim, OrderedDict):
                raise TypeError("dim must be an OrderedDict for python <3.6")
            if dim_kwargs:
>               raise ValueError("dim_kwargs isn't available for python <3.6")
E               ValueError: dim_kwargs isn't available for python <3.6

xarray/core/dataset.py:2659: ValueError
__________________________ test_coarsen_coords_cftime __________________________

    @requires_cftime
    def test_coarsen_coords_cftime():
>       times = xr.cftime_range('2000', periods=6)

xarray/tests/test_dataset.py:4956: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
xarray/coding/cftime_offsets.py:955: in cftime_range
    start = to_cftime_datetime(start, calendar)
xarray/coding/cftime_offsets.py:678: in to_cftime_datetime
    date, _ = _parse_iso8601_with_reso(get_date_type(calendar),
xarray/coding/cftimeindex.py:114: in _parse_iso8601_with_reso
    return default.replace(**replace), resolution
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

>   ???
E   ValueError: Replacing the dayofyr or dayofwk of a datetime is not supported.

src/cftime/_cftime.pyx:1315: ValueError
_______________________ test_differentiate_cftime[True] ________________________

dask = True

    @pytest.mark.skipif(not has_cftime, reason='Test requires cftime.')
    @pytest.mark.parametrize('dask', [True, False])
    def test_differentiate_cftime(dask):
        rs = np.random.RandomState(42)
>       coord = xr.cftime_range('2000', periods=8, freq='2M')

xarray/tests/test_dataset.py:5173: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
xarray/coding/cftime_offsets.py:955: in cftime_range
    start = to_cftime_datetime(start, calendar)
xarray/coding/cftime_offsets.py:678: in to_cftime_datetime
    date, _ = _parse_iso8601_with_reso(get_date_type(calendar),
xarray/coding/cftimeindex.py:114: in _parse_iso8601_with_reso
    return default.replace(**replace), resolution
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

>   ???
E   ValueError: Replacing the dayofyr or dayofwk of a datetime is not supported.

src/cftime/_cftime.pyx:1315: ValueError
_______________________ test_differentiate_cftime[False] _______________________

dask = False

    @pytest.mark.skipif(not has_cftime, reason='Test requires cftime.')
    @pytest.mark.parametrize('dask', [True, False])
    def test_differentiate_cftime(dask):
        rs = np.random.RandomState(42)
>       coord = xr.cftime_range('2000', periods=8, freq='2M')

xarray/tests/test_dataset.py:5173: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
xarray/coding/cftime_offsets.py:955: in cftime_range
    start = to_cftime_datetime(start, calendar)
xarray/coding/cftime_offsets.py:678: in to_cftime_datetime
    date, _ = _parse_iso8601_with_reso(get_date_type(calendar),
xarray/coding/cftimeindex.py:114: in _parse_iso8601_with_reso
    return default.replace(**replace), resolution
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

>   ???
E   ValueError: Replacing the dayofyr or dayofwk of a datetime is not supported.

src/cftime/_cftime.pyx:1315: ValueError
_______________________ test_trapz_datetime[cftime-True] _______________________

dask = True, which_datetime = 'cftime'

    @pytest.mark.parametrize('dask', [True, False])
    @pytest.mark.parametrize('which_datetime', ['np', 'cftime'])
    def test_trapz_datetime(dask, which_datetime):
        rs = np.random.RandomState(42)
        if which_datetime == 'np':
            coord = np.array(
                ['2004-07-13', '2006-01-13', '2010-08-13', '2010-09-13',
                 '2010-10-11', '2010-12-13', '2011-02-13', '2012-08-13'],
                dtype='datetime64')
        else:
            if not has_cftime:
                pytest.skip('Test requires cftime.')
>           coord = xr.cftime_range('2000', periods=8, freq='2D')

xarray/tests/test_dataset.py:5252: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
xarray/coding/cftime_offsets.py:955: in cftime_range
    start = to_cftime_datetime(start, calendar)
xarray/coding/cftime_offsets.py:678: in to_cftime_datetime
    date, _ = _parse_iso8601_with_reso(get_date_type(calendar),
xarray/coding/cftimeindex.py:114: in _parse_iso8601_with_reso
    return default.replace(**replace), resolution
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

>   ???
E   ValueError: Replacing the dayofyr or dayofwk of a datetime is not supported.

src/cftime/_cftime.pyx:1315: ValueError
______________________ test_trapz_datetime[cftime-False] _______________________

dask = False, which_datetime = 'cftime'

    @pytest.mark.parametrize('dask', [True, False])
    @pytest.mark.parametrize('which_datetime', ['np', 'cftime'])
    def test_trapz_datetime(dask, which_datetime):
        rs = np.random.RandomState(42)
        if which_datetime == 'np':
            coord = np.array(
                ['2004-07-13', '2006-01-13', '2010-08-13', '2010-09-13',
                 '2010-10-11', '2010-12-13', '2011-02-13', '2012-08-13'],
                dtype='datetime64')
        else:
            if not has_cftime:
                pytest.skip('Test requires cftime.')
>           coord = xr.cftime_range('2000', periods=8, freq='2D')

xarray/tests/test_dataset.py:5252: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
xarray/coding/cftime_offsets.py:955: in cftime_range
    start = to_cftime_datetime(start, calendar)
xarray/coding/cftime_offsets.py:678: in to_cftime_datetime
    date, _ = _parse_iso8601_with_reso(get_date_type(calendar),
xarray/coding/cftimeindex.py:114: in _parse_iso8601_with_reso
    return default.replace(**replace), resolution
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

>   ???
E   ValueError: Replacing the dayofyr or dayofwk of a datetime is not supported.

src/cftime/_cftime.pyx:1315: ValueError
=============================== warnings summary ===============================
xarray/core/dask_array_ops.py:11
xarray/core/dask_array_ops.py:11
  /testbed/xarray/core/dask_array_ops.py:11: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(dask.__version__) <= LooseVersion('0.18.2'):

xarray/core/npcompat.py:135
xarray/core/npcompat.py:135
  /testbed/xarray/core/npcompat.py:135: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(np.__version__) >= LooseVersion('1.13'):

xarray/core/dask_array_compat.py:43
xarray/core/dask_array_compat.py:43
  /testbed/xarray/core/dask_array_compat.py:43: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(dask_version) > LooseVersion('0.19.2'):

xarray/plot/utils.py:17
xarray/plot/utils.py:17
  /testbed/xarray/plot/utils.py:17: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(nc_time_axis.__version__) < LooseVersion('1.2.0'):

xarray/core/pdcompat.py:46
  /testbed/xarray/core/pdcompat.py:46: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(pd.__version__) < '0.25.0':

../opt/miniconda3/envs/testbed/lib/python3.10/site-packages/setuptools/_distutils/version.py:345: 2 warnings
xarray/tests/test_variable.py: 101 warnings
xarray/tests/test_dataarray.py: 78 warnings
xarray/tests/test_dataset.py: 53 warnings
  /opt/miniconda3/envs/testbed/lib/python3.10/site-packages/setuptools/_distutils/version.py:345: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    other = LooseVersion(other)

xarray/tests/__init__.py:57: 17 warnings
xarray/tests/test_dataarray.py: 2 warnings
xarray/tests/test_dataset.py: 1 warning
  /testbed/xarray/tests/__init__.py:57: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    return version.LooseVersion(vstring)

xarray/tests/test_variable.py: 12 warnings
xarray/tests/test_dataarray.py: 12 warnings
xarray/tests/test_dataset.py: 63 warnings
  /testbed/xarray/core/variable.py:1596: DeprecationWarning: the `interpolation=` argument to nanpercentile was renamed to `method=`, which has additional options.
  Users of the modes 'nearest', 'lower', 'higher', or 'midpoint' are encouraged to review the method they used. (Deprecated NumPy 1.22)
    qs = np.nanpercentile(self.data, q * 100., axis=axis,

xarray/tests/test_variable.py: 99 warnings
xarray/tests/test_dataarray.py: 61 warnings
xarray/tests/test_dataset.py: 45 warnings
  /testbed/xarray/core/variable.py:900: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(dask.__version__) > '1.2.2':

xarray/tests/test_variable.py::TestVariableWithDask::test_eq_all_dtypes
  /opt/miniconda3/envs/testbed/lib/python3.10/site-packages/dask/core.py:119: FutureWarning: elementwise comparison failed; returning scalar instead, but in the future will perform elementwise comparison
    return func(*(_execute_task(a, cache) for a in args))

xarray/tests/test_variable.py::TestVariableWithDask::test_equals_all_dtypes
  /testbed/xarray/tests/test_variable.py:1810: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if '0.18.2' <= LooseVersion(dask.__version__) < '0.19.1':

xarray/tests/test_variable.py::test_raise_no_warning_for_nan_in_binary_ops
xarray/tests/test_dataarray.py::test_raise_no_warning_for_nan_in_binary_ops
xarray/tests/test_dataset.py::TestDataset::test_reindex_warning
xarray/tests/test_dataset.py::test_raise_no_warning_for_nan_in_binary_ops
  /opt/miniconda3/envs/testbed/lib/python3.10/site-packages/_pytest/python.py:194: PytestRemovedIn8Warning: Passing None has been deprecated.
  See https://docs.pytest.org/en/latest/how-to/capture-warnings.html#additional-use-cases-of-warnings-in-tests for alternatives in common use cases.
    result = testfunction(**testargs)

xarray/tests/test_dataarray.py: 77 warnings
xarray/tests/test_dataset.py: 404 warnings
  /testbed/xarray/core/formatting.py:147: DeprecationWarning: `np.float` is a deprecated alias for the builtin `float`. To silence this warning, use `float` by itself. Doing this will not modify any behavior and is safe. If you specifically wanted the numpy scalar type, use `np.float64` here.
  Deprecated in NumPy 1.20; for more details and guidance: https://numpy.org/devdocs/release/1.20.0-notes.html#deprecations
    elif isinstance(x, (float, np.float)):

xarray/tests/test_dataarray.py: 5 warnings
xarray/tests/test_dataset.py: 6 warnings
  /testbed/xarray/core/alignment.py:138: FutureWarning: Index.__and__ operating as a set operation is deprecated, in the future this will be a logical operation matching Series.__and__.  Use index.intersection(other) instead.
    index = joiner(matching_indexes)

xarray/tests/test_dataarray.py: 34 warnings
xarray/tests/test_dataset.py: 30 warnings
  /testbed/xarray/core/dataset.py:2897: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(pd.__version__) < LooseVersion('0.19.0'):

xarray/tests/test_dataarray.py: 10 warnings
xarray/tests/test_dataset.py: 7 warnings
  /testbed/xarray/core/dataset.py:3073: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(pd.__version__) >= "0.20":

xarray/tests/test_dataarray.py: 14 warnings
xarray/tests/test_dataset.py: 19 warnings
  /testbed/xarray/core/alignment.py:138: FutureWarning: Index.__or__ operating as a set operation is deprecated, in the future this will be a logical operation matching Series.__or__.  Use index.union(other) instead.
    index = joiner(matching_indexes)

xarray/tests/test_dataarray.py::TestDataArray::test_reindex_regressions
  /testbed/xarray/tests/test_dataarray.py:1306: DeprecationWarning: `np.complex` is a deprecated alias for the builtin `complex`. To silence this warning, use `complex` by itself. Doing this will not modify any behavior and is safe. If you specifically wanted the numpy scalar type, use `np.complex128` here.
  Deprecated in NumPy 1.20; for more details and guidance: https://numpy.org/devdocs/release/1.20.0-notes.html#deprecations
    x = np.array([1, 2, 3], dtype=np.complex)

xarray/tests/test_dataarray.py::TestDataArray::test_stack_unstack
  /testbed/xarray/tests/test_dataarray.py:1792: FutureWarning: pandas.Int64Index is deprecated and will be removed from pandas in a future version. Use pandas.Index with the appropriate dtype instead.
    b = pd.MultiIndex(levels=[pd.Int64Index([]), pd.Int64Index([0])],

xarray/tests/test_dataarray.py::TestDataArray::test_stack_unstack
  /opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/util/__init__.py:16: FutureWarning: pandas.util.testing is deprecated. Use the functions in the public API at pandas.testing instead.
    import pandas.util.testing

xarray/tests/test_dataarray.py: 9 warnings
xarray/tests/test_dataset.py: 5 warnings
  /testbed/xarray/core/groupby.py:153: FutureWarning: is_monotonic is deprecated and will be removed in a future version. Use is_monotonic_increasing instead.
    return index.is_unique and index.is_monotonic

xarray/tests/test_dataarray.py::TestDataArray::test_groupby_bins_sort
  /testbed/xarray/tests/test_dataarray.py:2483: FutureWarning: is_monotonic is deprecated and will be removed in a future version. Use is_monotonic_increasing instead.
    assert binned_mean.to_index().is_monotonic

xarray/tests/test_dataarray.py: 41 warnings
xarray/tests/test_dataset.py: 10 warnings
  /testbed/xarray/core/common.py:840: FutureWarning: 'base' in .resample() and in Grouper() is deprecated.
  The new arguments that you should use are 'offset' or 'origin'.
  
  >>> df.resample(freq="3s", base=2)
  
  becomes:
  
  >>> df.resample(freq="3s", offset="2s")
  
    grouper = pd.Grouper(freq=freq, closed=closed, label=label,

xarray/tests/test_dataarray.py: 40 warnings
xarray/tests/test_dataset.py: 10 warnings
  /testbed/xarray/core/groupby.py:264: FutureWarning: is_monotonic is deprecated and will be removed in a future version. Use is_monotonic_increasing instead.
    if not index.is_monotonic:

xarray/tests/test_dataarray.py::TestDataArray::test_resample
xarray/tests/test_dataset.py::TestDataset::test_resample_loffset
  /testbed/xarray/core/common.py:840: FutureWarning: 'loffset' in .resample() and in Grouper() is deprecated.
  
  >>> df.resample(freq="3s", loffset="8H")
  
  becomes:
  
  >>> from pandas.tseries.frequencies import to_offset
  >>> df = df.resample(freq="3s").mean()
  >>> df.index = df.index.to_timestamp() + to_offset("8H")
  
    grouper = pd.Grouper(freq=freq, closed=closed, label=label,

xarray/tests/test_dataarray.py::TestDataArray::test_resample
  /testbed/xarray/tests/test_dataarray.py:2497: FutureWarning: 'loffset' in .resample() and in Grouper() is deprecated.
  
  >>> df.resample(freq="3s", loffset="8H")
  
  becomes:
  
  >>> from pandas.tseries.frequencies import to_offset
  >>> df = df.resample(freq="3s").mean()
  >>> df.index = df.index.to_timestamp() + to_offset("8H")
  
    expected = DataArray(array.to_series().resample('24H', loffset='-12H')

xarray/tests/test_dataarray.py::TestDataArray::test_resample_drop_nondim_coords
xarray/tests/test_dataarray.py::TestDataArray::test_upsample_interpolate
xarray/tests/test_dataarray.py::TestDataArray::test_upsample_interpolate
xarray/tests/test_dataarray.py::TestDataArray::test_upsample_interpolate_bug_2197
xarray/tests/test_dataarray.py::TestDataArray::test_upsample_interpolate_regression_1605
xarray/tests/test_dataarray.py::TestDataArray::test_upsample_interpolate_dask
xarray/tests/test_dataarray.py::TestDataArray::test_upsample_interpolate_dask
xarray/tests/test_dataarray.py::TestDataArray::test_upsample_interpolate_dask
xarray/tests/test_dataset.py::TestDataset::test_resample_drop_nondim_coords
  /testbed/xarray/core/missing.py:380: FutureWarning: Passing method to DatetimeIndex.get_loc is deprecated and will raise in a future version. Use index.get_indexer([item], method=...) instead.
    imin = index.get_loc(np.min(new_x.values), method='nearest')

xarray/tests/test_dataarray.py::TestDataArray::test_resample_drop_nondim_coords
xarray/tests/test_dataarray.py::TestDataArray::test_upsample_interpolate
xarray/tests/test_dataarray.py::TestDataArray::test_upsample_interpolate
xarray/tests/test_dataarray.py::TestDataArray::test_upsample_interpolate_bug_2197
xarray/tests/test_dataarray.py::TestDataArray::test_upsample_interpolate_regression_1605
xarray/tests/test_dataarray.py::TestDataArray::test_upsample_interpolate_dask
xarray/tests/test_dataarray.py::TestDataArray::test_upsample_interpolate_dask
xarray/tests/test_dataarray.py::TestDataArray::test_upsample_interpolate_dask
xarray/tests/test_dataset.py::TestDataset::test_resample_drop_nondim_coords
  /testbed/xarray/core/missing.py:381: FutureWarning: Passing method to DatetimeIndex.get_loc is deprecated and will raise in a future version. Use index.get_indexer([item], method=...) instead.
    imax = index.get_loc(np.max(new_x.values), method='nearest')

xarray/tests/test_dataarray.py::TestDataArray::test_upsample
  /testbed/xarray/tests/test_dataarray.py:2630: FutureWarning: pad is deprecated and will be removed in a future version. Use ffill instead.
    expected = DataArray(array.to_series().resample('3H').pad())

xarray/tests/test_dataarray.py::TestDataArray::test_to_and_from_empty_series
  /testbed/xarray/tests/test_dataarray.py:3083: FutureWarning: The default dtype for empty Series will be 'object' instead of 'float64' in a future version. Specify a dtype explicitly to silence this warning.
    expected = pd.Series([])

xarray/tests/test_dataarray.py::TestDataArray::test_to_and_from_cdms2_classic
xarray/tests/test_dataarray.py::TestIrisConversion::test_to_and_from_iris
xarray/tests/test_dataarray.py::TestIrisConversion::test_to_and_from_iris
xarray/tests/test_dataarray.py::TestIrisConversion::test_to_and_from_iris_dask
xarray/tests/test_dataarray.py::TestIrisConversion::test_to_and_from_iris_dask
  /testbed/xarray/coding/times.py:212: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(pd.__version__) < '0.25.0':

xarray/tests/test_dataarray.py::TestDataArray::test_to_and_from_cdms2_sgrid
xarray/tests/test_dataarray.py::TestDataArray::test_to_and_from_cdms2_sgrid
xarray/tests/test_dataarray.py::TestDataArray::test_to_and_from_cdms2_sgrid
xarray/tests/test_dataarray.py::TestDataArray::test_to_and_from_cdms2_sgrid
  /opt/miniconda3/envs/testbed/lib/python3.10/site-packages/numpy/ma/core.py:7939: DeprecationWarning: elementwise comparison failed; this will raise an error in the future.
    if not np.all(xinf == filled(np.isinf(y), False)):

xarray/tests/test_dataarray.py: 1952 warnings
xarray/tests/test_dataset.py: 5320 warnings
  /testbed/xarray/core/rolling.py:75: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    (LooseVersion(bottleneck.__version__) < LooseVersion('1.0'))):

xarray/tests/test_dataarray.py: 386 warnings
xarray/tests/test_dataset.py: 1016 warnings
  /testbed/xarray/core/rolling.py:322: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if (LooseVersion(np.__version__) < LooseVersion('1.13') and

xarray/tests/test_dataset.py::TestDataset::test_constructor_pandas_single
  /testbed/xarray/core/merge.py:321: FutureWarning: iteritems is deprecated and will be removed in a future version. Use .items instead.
    obj = OrderedDict(obj.iteritems())

xarray/tests/test_dataset.py::TestDataset::test_sel_method
xarray/tests/test_dataset.py::TestDataset::test_sel_method
xarray/tests/test_dataset.py::TestDataset::test_sel_method
  /testbed/xarray/core/indexing.py:108: FutureWarning: Passing method to Float64Index.get_loc is deprecated and will raise in a future version. Use index.get_indexer([item], method=...) instead.
    return index.get_loc(label, **kwargs)

xarray/tests/test_dataset.py::TestDataset::test_resample_loffset
  /testbed/xarray/tests/test_dataset.py:3226: FutureWarning: 'loffset' in .resample() and in Grouper() is deprecated.
  
  >>> df.resample(freq="3s", loffset="8H")
  
  becomes:
  
  >>> from pandas.tseries.frequencies import to_offset
  >>> df = df.resample(freq="3s").mean()
  >>> df.index = df.index.to_timestamp() + to_offset("8H")
  
    expected = xr.DataArray(ds.bar.to_series()

xarray/tests/test_dataset.py::TestDataset::test_sortby
xarray/tests/test_dataset.py::TestDataset::test_sortby
xarray/tests/test_dataset.py::TestDataset::test_sortby
xarray/tests/test_dataset.py::TestDataset::test_sortby
xarray/tests/test_dataset.py::TestDataset::test_sortby
xarray/tests/test_dataset.py::TestDataset::test_sortby
xarray/tests/test_dataset.py::TestDataset::test_sortby
xarray/tests/test_dataset.py::TestDataset::test_sortby
  /testbed/xarray/core/dataset.py:4390: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    and LooseVersion(np.__version__) < LooseVersion('1.11.0')):

xarray/tests/test_dataset.py::test_coarsen_coords[1-True]
xarray/tests/test_dataset.py::test_coarsen_coords[1-False]
  /testbed/xarray/tests/test_dataset.py:4950: UserWarning: Parsing dates in DD/MM/YYYY format when dayfirst=False (the default) was specified. This may lead to inconsistently parsed dates! Specify a format to ensure consistent parsing.
    coords={'time': pd.date_range('15/12/1999', periods=364)})

-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
=========================== short test summary info ============================
FAILED xarray/tests/test_dataset.py::TestDataset::test_expand_dims_error - As...
FAILED xarray/tests/test_dataset.py::TestDataset::test_expand_dims_kwargs_python36plus
FAILED xarray/tests/test_dataset.py::test_coarsen_coords_cftime - ValueError:...
FAILED xarray/tests/test_dataset.py::test_differentiate_cftime[True] - ValueE...
FAILED xarray/tests/test_dataset.py::test_differentiate_cftime[False] - Value...
FAILED xarray/tests/test_dataset.py::test_trapz_datetime[cftime-True] - Value...
FAILED xarray/tests/test_dataset.py::test_trapz_datetime[cftime-False] - Valu...
7 failed, 1729 passed, 19 skipped, 11 xfailed, 4 xpassed, 10007 warnings in 25.84s

the Check fails on the tree as the run found it too (baseline-check.log), and this change adds no failing test to it: it passes
scope: xarray/core/indexing.py xarray/core/variable.py xarray/tests/test_variable.py xarray/tests/test_dataarray.py xarray/tests/test_dataset.py
changed: xarray/core/variable.py +2 -1
changed: xarray/tests/test_dataarray.py +11 -1
changed: xarray/tests/test_dataset.py +10 -0
changed: xarray/tests/test_variable.py +8 -0
```

### `final-status.txt`

```
0
```

### `head.txt`

```
main
```

### `keep.txt`

```
kept: the direct attempt, untouched
```

### `notes.md`

```
# Notes, run 2026-11-06T123029

## Solver decision

## Review

## Repair
```

### `outline.md`

````
# The prompt

REGRESSION: copy(deep=True) casts unicode indices to object
Dataset.copy(deep=True) and DataArray.copy (deep=True/False) accidentally cast IndexVariable's with dtype='<U*' to object. Same applies to copy.copy() and copy.deepcopy().

This is a regression in xarray >= 0.12.2. xarray 0.12.1 and earlier are unaffected.

```

In [1]: ds = xarray.Dataset(
   ...:     coords={'x': ['foo'], 'y': ('x', ['bar'])},
   ...:     data_vars={'z': ('x', ['baz'])})                                                              

In [2]: ds                                                                                                                                                                                                                     
Out[2]: 
<xarray.Dataset>
Dimensions:  (x: 1)
Coordinates:
  * x        (x) <U3 'foo'
    y        (x) <U3 'bar'
Data variables:
    z        (x) <U3 'baz'

In [3]: ds.copy()                                                                                                                                                                                                              
Out[3]: 
<xarray.Dataset>
Dimensions:  (x: 1)
Coordinates:
  * x        (x) <U3 'foo'
    y        (x) <U3 'bar'
Data variables:
    z        (x) <U3 'baz'

In [4]: ds.copy(deep=True)                                                                                                                                                                                                     
Out[4]: 
<xarray.Dataset>
Dimensions:  (x: 1)
Coordinates:
  * x        (x) object 'foo'
    y        (x) <U3 'bar'
Data variables:
    z        (x) <U3 'baz'

In [5]: ds.z                                                                                                                                                                                                                   
Out[5]: 
<xarray.DataArray 'z' (x: 1)>
array(['baz'], dtype='<U3')
Coordinates:
  * x        (x) <U3 'foo'
    y        (x) <U3 'bar'

In [6]: ds.z.copy()                                                                                                                                                                                                            
Out[6]: 
<xarray.DataArray 'z' (x: 1)>
array(['baz'], dtype='<U3')
Coordinates:
  * x        (x) object 'foo'
    y        (x) <U3 'bar'

In [7]: ds.z.copy(deep=True)                                                                                                                                                                                                   
Out[7]: 
<xarray.DataArray 'z' (x: 1)>
array(['baz'], dtype='<U3')
Coordinates:
  * x        (x) object 'foo'
    y        (x) <U3 'bar'
```


# The files of the project

```
.codecov.yml
.coveragerc
.gitattributes
.github/ISSUE_TEMPLATE/bug_report.md
.github/PULL_REQUEST_TEMPLATE.md
.github/stale.yml
.gitignore
.landscape.yml
.pep8speaks.yml
CODE_OF_CONDUCT.md
HOW_TO_RELEASE
LICENSE
MANIFEST.in
README.rst
asv_bench/asv.conf.json
asv_bench/benchmarks/__init__.py
asv_bench/benchmarks/combine.py
asv_bench/benchmarks/dataarray_missing.py
asv_bench/benchmarks/dataset_io.py
asv_bench/benchmarks/indexing.py
asv_bench/benchmarks/interp.py
asv_bench/benchmarks/reindexing.py
asv_bench/benchmarks/rolling.py
asv_bench/benchmarks/unstacking.py
azure-pipelines.yml
ci/azure/add-conda-to-path.yml
ci/azure/install.yml
ci/azure/unit-tests.yml
ci/requirements/py35-min.yml
ci/requirements/py36-hypothesis.yml
ci/requirements/py36.yml
ci/requirements/py37-windows.yml
ci/requirements/py37.yml
conftest.py
doc/Makefile
doc/README.rst
doc/_static/.gitignore
doc/_static/advanced_selection_interpolation.svg
doc/_static/ci.png
doc/_static/dask_array.png
doc/_static/dataset-diagram-build.sh
doc/_static/dataset-diagram-logo.png
doc/_static/dataset-diagram-logo.tex
doc/_static/dataset-diagram-square-logo.png
doc/_static/dataset-diagram-square-logo.tex
doc/_static/dataset-diagram.png
doc/_static/dataset-diagram.tex
doc/_static/favicon.ico
doc/_static/numfocus_logo.png
doc/_static/opendap-prism-tmax.png
doc/_static/style.css
doc/_templates/layout.html
doc/api-hidden.rst
doc/api.rst
doc/combining.rst
doc/computation.rst
doc/conf.py
doc/contributing.rst
doc/dask.rst
doc/data-structures.rst
doc/environment.yml
doc/examples.rst
doc/examples/_code/accessor_example.py
doc/examples/_code/weather_data_setup.py
doc/examples/monthly-means.rst
doc/examples/monthly_means_output.png
doc/examples/multidimensional-coords.rst
doc/examples/weather-data.rst
doc/faq.rst
doc/gallery/README.txt
doc/gallery/plot_cartopy_facetgrid.py
doc/gallery/plot_colorbar_center.py
doc/gallery/plot_control_colorbar.py
doc/gallery/plot_lines_from_2d.py
doc/gallery/plot_rasterio.py
doc/gallery/plot_rasterio_rgb.py
doc/groupby.rst
doc/index.rst
doc/indexing.rst
doc/installing.rst
doc/internals.rst
doc/interpolation.rst
doc/io.rst
doc/pandas.rst
doc/plotting.rst
doc/quick-overview.rst
doc/related-projects.rst
doc/reshaping.rst
doc/roadmap.rst
doc/time-series.rst
doc/weather-climate.rst
doc/whats-new.rst
doc/why-xarray.rst
examples/xarray_multidimensional_coords.ipynb
examples/xarray_seasonal_means.ipynb
licenses/DASK_LICENSE
licenses/NUMPY_LICENSE
licenses/PANDAS_LICENSE
licenses/PYTHON_LICENSE
licenses/SEABORN_LICENSE
properties/README.md
properties/test_encode_decode.py
readthedocs.yml
setup.cfg
setup.py
versioneer.py
xarray/__init__.py
xarray/_version.py
xarray/backends/__init__.py
xarray/backends/api.py
xarray/backends/cfgrib_.py
xarray/backends/common.py
xarray/backends/file_manager.py
xarray/backends/h5netcdf_.py
xarray/backends/locks.py
xarray/backends/lru_cache.py
xarray/backends/memory.py
xarray/backends/netCDF4_.py
xarray/backends/netcdf3.py
xarray/backends/pseudonetcdf_.py
xarray/backends/pydap_.py
xarray/backends/pynio_.py
xarray/backends/rasterio_.py
xarray/backends/scipy_.py
xarray/backends/zarr.py
xarray/coding/__init__.py
xarray/coding/cftime_offsets.py
xarray/coding/cftimeindex.py
xarray/coding/strings.py
xarray/coding/times.py
xarray/coding/variables.py
xarray/conventions.py
xarray/convert.py
xarray/core/__init__.py
xarray/core/accessor_dt.py
xarray/core/accessor_str.py
xarray/core/alignment.py
xarray/core/arithmetic.py
xarray/core/combine.py
xarray/core/common.py
xarray/core/computation.py
xarray/core/concat.py
xarray/core/coordinates.py
xarray/core/dask_array_compat.py
xarray/core/dask_array_ops.py
xarray/core/dataarray.py
xarray/core/dataset.py
xarray/core/dtypes.py
xarray/core/duck_array_ops.py
xarray/core/extensions.py
xarray/core/formatting.py
xarray/core/groupby.py
xarray/core/indexes.py
xarray/core/indexing.py
xarray/core/merge.py
xarray/core/missing.py
xarray/core/nanops.py
xarray/core/npcompat.py
xarray/core/nputils.py
xarray/core/ops.py
xarray/core/options.py
xarray/core/pdcompat.py
xarray/core/pycompat.py
xarray/core/resample.py
xarray/core/resample_cftime.py
xarray/core/rolling.py
xarray/core/rolling_exp.py
xarray/core/utils.py
xarray/core/variable.py
xarray/plot/__init__.py
xarray/plot/facetgrid.py
xarray/plot/plot.py
xarray/plot/utils.py
xarray/py.typed
xarray/testing.py
xarray/tests/__init__.py
xarray/tests/data/bears.nc
xarray/tests/data/example.grib
xarray/tests/data/example.ict
xarray/tests/data/example.uamiv
xarray/tests/data/example_1.nc
xarray/tests/data/example_1.nc.gz
xarray/tests/test_accessor_dt.py
xarray/tests/test_accessor_str.py
xarray/tests/test_backends.py
xarray/tests/test_backends_api.py
xarray/tests/test_backends_common.py
xarray/tests/test_backends_file_manager.py
xarray/tests/test_backends_locks.py
xarray/tests/test_backends_lru_cache.py
xarray/tests/test_cftime_offsets.py
xarray/tests/test_cftimeindex.py
xarray/tests/test_cftimeindex_resample.py
xarray/tests/test_coding.py
xarray/tests/test_coding_strings.py
xarray/tests/test_coding_times.py
xarray/tests/test_combine.py
xarray/tests/test_computation.py
xarray/tests/test_concat.py
xarray/tests/test_conventions.py
xarray/tests/test_dask.py
xarray/tests/test_dataarray.py
xarray/tests/test_dataset.py
xarray/tests/test_distributed.py
xarray/tests/test_dtypes.py
xarray/tests/test_duck_array_ops.py
xarray/tests/test_extensions.py
xarray/tests/test_formatting.py
xarray/tests/test_groupby.py
xarray/tests/test_indexing.py
xarray/tests/test_interp.py
xarray/tests/test_merge.py
xarray/tests/test_missing.py
xarray/tests/test_nputils.py
xarray/tests/test_options.py
xarray/tests/test_plot.py
xarray/tests/test_print_versions.py
xarray/tests/test_testing.py
xarray/tests/test_tutorial.py
xarray/tests/test_ufuncs.py
xarray/tests/test_utils.py
xarray/tests/test_variable.py
xarray/tutorial.py
xarray/ufuncs.py
xarray/util/__init__.py
xarray/util/print_versions.py
```


# The last commit

```
779ee654 SWE-bench


```

```diff

```
````

### `plan.md`

```
## Deliverable
changes to this tree

## Check
`pytest xarray/tests/test_variable.py xarray/tests/test_dataarray.py xarray/tests/test_dataset.py -q`

## Scope
`xarray/core/indexing.py`
`xarray/core/variable.py`
`xarray/tests/test_variable.py`
`xarray/tests/test_dataarray.py`
`xarray/tests/test_dataset.py`

## Done when
- `Dataset.copy(deep=True)` preserves a unicode index coordinate’s dtype as `<U*`, not `object`.
- `DataArray.copy(deep=True)` and `DataArray.copy(deep=False)` preserve a unicode index coordinate’s dtype as `<U*`.
- `copy.copy()` and `copy.deepcopy()` on `Dataset`, `DataArray`, and `IndexVariable` preserve unicode index dtype.
- The copied index still contains the same values and remains usable as an index.

## Approach
The regression is in the index adapter’s copy path: deep-copying an `IndexVariable` rebuilds the adapter from a copied `pandas.Index`, whose dtype is `object`, and drops the original numpy dtype (`<U*`). Preserve the adapter’s stored dtype when copying.

Candidate approaches:
1. Minimal fix in `PandasIndexAdapter.copy`: pass `dtype=self._dtype` in both deep and shallow branches. This covers `Variable.copy`, `Dataset.copy`, `DataArray.copy`, and the `copy` module paths if they route through the adapter.
2. Override `IndexVariable.copy` / `__copy__` / `__deepcopy__` to preserve dtype explicitly. More code and more places to keep consistent; risks missing adapter-level copies.
3. Change `PandasIndexAdapter.__init__` to infer dtype from the original array before converting to `pandas.Index`. Broader behavior change and more likely to affect unrelated construction paths.

Add focused regression tests for unicode index coordinates under `Dataset.copy(deep=True)`, `DataArray.copy(deep=True/False)`, and `copy.copy` / `copy.deepcopy`.
```

### `prompt.md`

````
REGRESSION: copy(deep=True) casts unicode indices to object
Dataset.copy(deep=True) and DataArray.copy (deep=True/False) accidentally cast IndexVariable's with dtype='<U*' to object. Same applies to copy.copy() and copy.deepcopy().

This is a regression in xarray >= 0.12.2. xarray 0.12.1 and earlier are unaffected.

```

In [1]: ds = xarray.Dataset(
   ...:     coords={'x': ['foo'], 'y': ('x', ['bar'])},
   ...:     data_vars={'z': ('x', ['baz'])})                                                              

In [2]: ds                                                                                                                                                                                                                     
Out[2]: 
<xarray.Dataset>
Dimensions:  (x: 1)
Coordinates:
  * x        (x) <U3 'foo'
    y        (x) <U3 'bar'
Data variables:
    z        (x) <U3 'baz'

In [3]: ds.copy()                                                                                                                                                                                                              
Out[3]: 
<xarray.Dataset>
Dimensions:  (x: 1)
Coordinates:
  * x        (x) <U3 'foo'
    y        (x) <U3 'bar'
Data variables:
    z        (x) <U3 'baz'

In [4]: ds.copy(deep=True)                                                                                                                                                                                                     
Out[4]: 
<xarray.Dataset>
Dimensions:  (x: 1)
Coordinates:
  * x        (x) object 'foo'
    y        (x) <U3 'bar'
Data variables:
    z        (x) <U3 'baz'

In [5]: ds.z                                                                                                                                                                                                                   
Out[5]: 
<xarray.DataArray 'z' (x: 1)>
array(['baz'], dtype='<U3')
Coordinates:
  * x        (x) <U3 'foo'
    y        (x) <U3 'bar'

In [6]: ds.z.copy()                                                                                                                                                                                                            
Out[6]: 
<xarray.DataArray 'z' (x: 1)>
array(['baz'], dtype='<U3')
Coordinates:
  * x        (x) object 'foo'
    y        (x) <U3 'bar'

In [7]: ds.z.copy(deep=True)                                                                                                                                                                                                   
Out[7]: 
<xarray.DataArray 'z' (x: 1)>
array(['baz'], dtype='<U3')
Coordinates:
  * x        (x) object 'foo'
    y        (x) <U3 'bar'
```
````

### `review.md`

```
verdict: PASS
The fix passes `dtype=self._data.dtype` when rebuilding the `PandasIndexAdapter` in `IndexVariable.copy`, so deep copies no longer infer `object` from the underlying pandas index.
Shallow copies and `copy.copy`/`copy.deepcopy` route through `IndexVariable.copy`, so `Dataset`, `DataArray`, and `IndexVariable` copies preserve the unicode index dtype.
The added tests cover `Dataset.copy`, `DataArray.copy(deep=True/False)`, `copy`/`deepcopy`, and `IndexVariable.copy`, and they pass in the check output.
The 7 pytest failures are pre-existing baseline failures (`expand_dims` Python-version handling and cftime incompatibility), not introduced by this change; the check status is 0 and no new failing test was added.
No out-of-scope files were changed.
```

### `scope.txt`

```
scope: xarray/core/indexing.py xarray/core/variable.py xarray/tests/test_variable.py xarray/tests/test_dataarray.py xarray/tests/test_dataset.py
changed: xarray/core/variable.py +2 -1
changed: xarray/tests/test_dataarray.py +11 -1
changed: xarray/tests/test_dataset.py +10 -0
changed: xarray/tests/test_variable.py +8 -0
```

### `task.md`

````
# Task

## Prompt

REGRESSION: copy(deep=True) casts unicode indices to object
Dataset.copy(deep=True) and DataArray.copy (deep=True/False) accidentally cast IndexVariable's with dtype='<U*' to object. Same applies to copy.copy() and copy.deepcopy().

This is a regression in xarray >= 0.12.2. xarray 0.12.1 and earlier are unaffected.

```

In [1]: ds = xarray.Dataset(
   ...:     coords={'x': ['foo'], 'y': ('x', ['bar'])},
   ...:     data_vars={'z': ('x', ['baz'])})                                                              

In [2]: ds                                                                                                                                                                                                                     
Out[2]: 
<xarray.Dataset>
Dimensions:  (x: 1)
Coordinates:
  * x        (x) <U3 'foo'
    y        (x) <U3 'bar'
Data variables:
    z        (x) <U3 'baz'

In [3]: ds.copy()                                                                                                                                                                                                              
Out[3]: 
<xarray.Dataset>
Dimensions:  (x: 1)
Coordinates:
  * x        (x) <U3 'foo'
    y        (x) <U3 'bar'
Data variables:
    z        (x) <U3 'baz'

In [4]: ds.copy(deep=True)                                                                                                                                                                                                     
Out[4]: 
<xarray.Dataset>
Dimensions:  (x: 1)
Coordinates:
  * x        (x) object 'foo'
    y        (x) <U3 'bar'
Data variables:
    z        (x) <U3 'baz'

In [5]: ds.z                                                                                                                                                                                                                   
Out[5]: 
<xarray.DataArray 'z' (x: 1)>
array(['baz'], dtype='<U3')
Coordinates:
  * x        (x) <U3 'foo'
    y        (x) <U3 'bar'

In [6]: ds.z.copy()                                                                                                                                                                                                            
Out[6]: 
<xarray.DataArray 'z' (x: 1)>
array(['baz'], dtype='<U3')
Coordinates:
  * x        (x) object 'foo'
    y        (x) <U3 'bar'

In [7]: ds.z.copy(deep=True)                                                                                                                                                                                                   
Out[7]: 
<xarray.DataArray 'z' (x: 1)>
array(['baz'], dtype='<U3')
Coordinates:
  * x        (x) object 'foo'
    y        (x) <U3 'bar'
```

## Deliverable

changes to this tree

## Check

`pytest xarray/tests/test_variable.py xarray/tests/test_dataarray.py xarray/tests/test_dataset.py -q`

## Scope

`xarray/core/indexing.py`
`xarray/core/variable.py`
`xarray/tests/test_variable.py`
`xarray/tests/test_dataarray.py`
`xarray/tests/test_dataset.py`

## Done when

- `Dataset.copy(deep=True)` preserves a unicode index coordinate’s dtype as `<U*`, not `object`.
- `DataArray.copy(deep=True)` and `DataArray.copy(deep=False)` preserve a unicode index coordinate’s dtype as `<U*`.
- `copy.copy()` and `copy.deepcopy()` on `Dataset`, `DataArray`, and `IndexVariable` preserve unicode index dtype.
- The copied index still contains the same values and remains usable as an index.
````

### `test-output.log`

```
check: pytest xarray/tests/test_variable.py xarray/tests/test_dataarray.py xarray/tests/test_dataset.py -q
........................................................................ [  4%]
........................................................................ [  8%]
....................xxxx................................................ [ 12%]
..................xxxxxxx............................................... [ 16%]
........................................................................ [ 20%]
................s.s..................................................... [ 24%]
......................XX................................................ [ 28%]
........................................................................ [ 32%]
........................................................................ [ 36%]
........................................................................ [ 40%]
........................................................................ [ 44%]
........................................................................ [ 48%]
........................................................................ [ 52%]
...............................................................XX....... [ 56%]
.F.....sF............................................................... [ 61%]
........................................................................ [ 65%]
............................F........................................... [ 69%]
........................................................................ [ 73%]
........................................................................ [ 77%]
...................................................................sssss [ 81%]
sssssssssss............................................................. [ 85%]
........................................................................ [ 89%]
........................................................................ [ 93%]
........................................................................ [ 97%]
..................................FF....FF                               [100%]
=================================== FAILURES ===================================
______________________ TestDataset.test_expand_dims_error ______________________

self = <xarray.tests.test_dataset.TestDataset object at 0x77662ec7be20>

    def test_expand_dims_error(self):
        original = Dataset({'x': ('a', np.random.randn(3)),
                            'y': (['b', 'a'], np.random.randn(4, 3)),
                            'z': ('a', np.random.randn(3))},
                           coords={'a': np.linspace(0, 1, 3),
                                   'b': np.linspace(0, 1, 4),
                                   'c': np.linspace(0, 1, 5)},
                           attrs={'key': 'entry'})
    
        with raises_regex(ValueError, 'already exists'):
            original.expand_dims(dim=['x'])
    
        # Make sure it raises true error also for non-dimensional coordinates
        # which has dimension.
        original = original.set_coords('z')
        with raises_regex(ValueError, 'already exists'):
            original.expand_dims(dim=['z'])
    
        original = Dataset({'x': ('a', np.random.randn(3)),
                            'y': (['b', 'a'], np.random.randn(4, 3)),
                            'z': ('a', np.random.randn(3))},
                           coords={'a': np.linspace(0, 1, 3),
                                   'b': np.linspace(0, 1, 4),
                                   'c': np.linspace(0, 1, 5)},
                           attrs={'key': 'entry'})
        with raises_regex(TypeError, 'value of new dimension'):
            original.expand_dims(OrderedDict((("d", 3.2),)))
    
        # TODO: only the code under the if-statement is needed when python 3.5
        #   is no longer supported.
        python36_plus = sys.version_info[0] == 3 and sys.version_info[1] > 5
        if python36_plus:
            with raises_regex(ValueError, 'both keyword and positional'):
>               original.expand_dims(OrderedDict((("d", 4),)), e=4)

xarray/tests/test_dataset.py:2283: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <xarray.Dataset>
Dimensions:  (a: 3, b: 4, c: 5)
Coordinates:
  * a        (a) float64 0.0 0.5 1.0
  * b        (b) fl...1 1.454 0.8344 ... 0.07422 0.673 0.3079
    z        (a) float64 -0.1999 0.6246 -0.6816
Attributes:
    key:      entry
dim = OrderedDict([('d', 4)]), axis = None, dim_kwargs = {'e': 4}

    def expand_dims(
        self,
        dim: Union[None, Hashable, Sequence[Hashable],
                   Mapping[Hashable, Any]] = None,
        axis: Union[None, int, Sequence[int]] = None,
        **dim_kwargs: Any
    ) -> 'Dataset':
        """Return a new object with an additional axis (or axes) inserted at
        the corresponding position in the array shape.  The new object is a
        view into the underlying array, not a copy.
    
        If dim is already a scalar coordinate, it will be promoted to a 1D
        coordinate consisting of a single value.
    
        Parameters
        ----------
        dim : hashable, sequence of hashable, mapping, or None
            Dimensions to include on the new variable. If provided as hashable
            or sequence of hashable, then dimensions are inserted with length
            1. If provided as a mapping, then the keys are the new dimensions
            and the values are either integers (giving the length of the new
            dimensions) or array-like (giving the coordinates of the new
            dimensions).
    
            .. note::
    
               For Python 3.5, if ``dim`` is a mapping, then it must be an
               ``OrderedDict``. This is to ensure that the order in which the
               dims are given is maintained.
    
        axis : integer, sequence of integers, or None
            Axis position(s) where new axis is to be inserted (position(s) on
            the result array). If a list (or tuple) of integers is passed,
            multiple axes are inserted. In this case, dim arguments should be
            same length list. If axis=None is passed, all the axes will be
            inserted to the start of the result array.
        **dim_kwargs : int or sequence/ndarray
            The keywords are arbitrary dimensions being inserted and the values
            are either the lengths of the new dims (if int is given), or their
            coordinates. Note, this is an alternative to passing a dict to the
            dim kwarg and will only be used if dim is None.
    
            .. note::
    
               For Python 3.5, ``dim_kwargs`` is not available.
    
        Returns
        -------
        expanded : same type as caller
            This object, but with an additional dimension(s).
        """
        # TODO: get rid of the below code block when python 3.5 is no longer
        #   supported.
        if sys.version < '3.6':
            if isinstance(dim, Mapping) and not isinstance(dim, OrderedDict):
                raise TypeError("dim must be an OrderedDict for python <3.6")
            if dim_kwargs:
>               raise ValueError("dim_kwargs isn't available for python <3.6")
E               ValueError: dim_kwargs isn't available for python <3.6

xarray/core/dataset.py:2659: ValueError

During handling of the above exception, another exception occurred:

self = <xarray.tests.test_dataset.TestDataset object at 0x77662ec7be20>

    def test_expand_dims_error(self):
        original = Dataset({'x': ('a', np.random.randn(3)),
                            'y': (['b', 'a'], np.random.randn(4, 3)),
                            'z': ('a', np.random.randn(3))},
                           coords={'a': np.linspace(0, 1, 3),
                                   'b': np.linspace(0, 1, 4),
                                   'c': np.linspace(0, 1, 5)},
                           attrs={'key': 'entry'})
    
        with raises_regex(ValueError, 'already exists'):
            original.expand_dims(dim=['x'])
    
        # Make sure it raises true error also for non-dimensional coordinates
        # which has dimension.
        original = original.set_coords('z')
        with raises_regex(ValueError, 'already exists'):
            original.expand_dims(dim=['z'])
    
        original = Dataset({'x': ('a', np.random.randn(3)),
                            'y': (['b', 'a'], np.random.randn(4, 3)),
                            'z': ('a', np.random.randn(3))},
                           coords={'a': np.linspace(0, 1, 3),
                                   'b': np.linspace(0, 1, 4),
                                   'c': np.linspace(0, 1, 5)},
                           attrs={'key': 'entry'})
        with raises_regex(TypeError, 'value of new dimension'):
            original.expand_dims(OrderedDict((("d", 3.2),)))
    
        # TODO: only the code under the if-statement is needed when python 3.5
        #   is no longer supported.
        python36_plus = sys.version_info[0] == 3 and sys.version_info[1] > 5
        if python36_plus:
>           with raises_regex(ValueError, 'both keyword and positional'):

xarray/tests/test_dataset.py:2282: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <contextlib._GeneratorContextManager object at 0x7766250d8190>
typ = <class 'ValueError'>
value = ValueError("dim_kwargs isn't available for python <3.6")
traceback = <traceback object at 0x7766250dd140>

    def __exit__(self, typ, value, traceback):
        if typ is None:
            try:
                next(self.gen)
            except StopIteration:
                return False
            else:
                raise RuntimeError("generator didn't stop")
        else:
            if value is None:
                # Need to force instantiation so we can reliably
                # tell if we get the same exception back
                value = typ()
            try:
>               self.gen.throw(typ, value, traceback)
E               AssertionError: exception ValueError("dim_kwargs isn't available for python <3.6") did not match pattern 'both keyword and positional'

/opt/miniconda3/envs/testbed/lib/python3.10/contextlib.py:153: AssertionError
_______________ TestDataset.test_expand_dims_kwargs_python36plus _______________

self = <xarray.tests.test_dataset.TestDataset object at 0x77662eaa8640>

    @pytest.mark.skipif(
        sys.version_info[:2] < (3, 6),
        reason='keyword arguments are only ordered on Python 3.6+',
    )
    def test_expand_dims_kwargs_python36plus(self):
        original = Dataset({'x': ('a', np.random.randn(3)),
                            'y': (['b', 'a'], np.random.randn(4, 3))},
                           coords={'a': np.linspace(0, 1, 3),
                                   'b': np.linspace(0, 1, 4),
                                   'c': np.linspace(0, 1, 5)},
                           attrs={'key': 'entry'})
>       other_way = original.expand_dims(e=["l", "m", "n"])

xarray/tests/test_dataset.py:2389: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <xarray.Dataset>
Dimensions:  (a: 3, b: 4, c: 5)
Coordinates:
  * a        (a) float64 0.0 0.5 1.0
  * b        (b) fl...6 -0.2457
    y        (b, a) float64 -0.9673 -0.2682 0.4863 ... -1.767 0.008608 0.9637
Attributes:
    key:      entry
dim = None, axis = None, dim_kwargs = {'e': ['l', 'm', 'n']}

    def expand_dims(
        self,
        dim: Union[None, Hashable, Sequence[Hashable],
                   Mapping[Hashable, Any]] = None,
        axis: Union[None, int, Sequence[int]] = None,
        **dim_kwargs: Any
    ) -> 'Dataset':
        """Return a new object with an additional axis (or axes) inserted at
        the corresponding position in the array shape.  The new object is a
        view into the underlying array, not a copy.
    
        If dim is already a scalar coordinate, it will be promoted to a 1D
        coordinate consisting of a single value.
    
        Parameters
        ----------
        dim : hashable, sequence of hashable, mapping, or None
            Dimensions to include on the new variable. If provided as hashable
            or sequence of hashable, then dimensions are inserted with length
            1. If provided as a mapping, then the keys are the new dimensions
            and the values are either integers (giving the length of the new
            dimensions) or array-like (giving the coordinates of the new
            dimensions).
    
            .. note::
    
               For Python 3.5, if ``dim`` is a mapping, then it must be an
               ``OrderedDict``. This is to ensure that the order in which the
               dims are given is maintained.
    
        axis : integer, sequence of integers, or None
            Axis position(s) where new axis is to be inserted (position(s) on
            the result array). If a list (or tuple) of integers is passed,
            multiple axes are inserted. In this case, dim arguments should be
            same length list. If axis=None is passed, all the axes will be
            inserted to the start of the result array.
        **dim_kwargs : int or sequence/ndarray
            The keywords are arbitrary dimensions being inserted and the values
            are either the lengths of the new dims (if int is given), or their
            coordinates. Note, this is an alternative to passing a dict to the
            dim kwarg and will only be used if dim is None.
    
            .. note::
    
               For Python 3.5, ``dim_kwargs`` is not available.
    
        Returns
        -------
        expanded : same type as caller
            This object, but with an additional dimension(s).
        """
        # TODO: get rid of the below code block when python 3.5 is no longer
        #   supported.
        if sys.version < '3.6':
            if isinstance(dim, Mapping) and not isinstance(dim, OrderedDict):
                raise TypeError("dim must be an OrderedDict for python <3.6")
            if dim_kwargs:
>               raise ValueError("dim_kwargs isn't available for python <3.6")
E               ValueError: dim_kwargs isn't available for python <3.6

xarray/core/dataset.py:2659: ValueError
__________________________ test_coarsen_coords_cftime __________________________

    @requires_cftime
    def test_coarsen_coords_cftime():
>       times = xr.cftime_range('2000', periods=6)

xarray/tests/test_dataset.py:4956: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
xarray/coding/cftime_offsets.py:955: in cftime_range
    start = to_cftime_datetime(start, calendar)
xarray/coding/cftime_offsets.py:678: in to_cftime_datetime
    date, _ = _parse_iso8601_with_reso(get_date_type(calendar),
xarray/coding/cftimeindex.py:114: in _parse_iso8601_with_reso
    return default.replace(**replace), resolution
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

>   ???
E   ValueError: Replacing the dayofyr or dayofwk of a datetime is not supported.

src/cftime/_cftime.pyx:1315: ValueError
_______________________ test_differentiate_cftime[True] ________________________

dask = True

    @pytest.mark.skipif(not has_cftime, reason='Test requires cftime.')
    @pytest.mark.parametrize('dask', [True, False])
    def test_differentiate_cftime(dask):
        rs = np.random.RandomState(42)
>       coord = xr.cftime_range('2000', periods=8, freq='2M')

xarray/tests/test_dataset.py:5173: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
xarray/coding/cftime_offsets.py:955: in cftime_range
    start = to_cftime_datetime(start, calendar)
xarray/coding/cftime_offsets.py:678: in to_cftime_datetime
    date, _ = _parse_iso8601_with_reso(get_date_type(calendar),
xarray/coding/cftimeindex.py:114: in _parse_iso8601_with_reso
    return default.replace(**replace), resolution
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

>   ???
E   ValueError: Replacing the dayofyr or dayofwk of a datetime is not supported.

src/cftime/_cftime.pyx:1315: ValueError
_______________________ test_differentiate_cftime[False] _______________________

dask = False

    @pytest.mark.skipif(not has_cftime, reason='Test requires cftime.')
    @pytest.mark.parametrize('dask', [True, False])
    def test_differentiate_cftime(dask):
        rs = np.random.RandomState(42)
>       coord = xr.cftime_range('2000', periods=8, freq='2M')

xarray/tests/test_dataset.py:5173: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
xarray/coding/cftime_offsets.py:955: in cftime_range
    start = to_cftime_datetime(start, calendar)
xarray/coding/cftime_offsets.py:678: in to_cftime_datetime
    date, _ = _parse_iso8601_with_reso(get_date_type(calendar),
xarray/coding/cftimeindex.py:114: in _parse_iso8601_with_reso
    return default.replace(**replace), resolution
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

>   ???
E   ValueError: Replacing the dayofyr or dayofwk of a datetime is not supported.

src/cftime/_cftime.pyx:1315: ValueError
_______________________ test_trapz_datetime[cftime-True] _______________________

dask = True, which_datetime = 'cftime'

    @pytest.mark.parametrize('dask', [True, False])
    @pytest.mark.parametrize('which_datetime', ['np', 'cftime'])
    def test_trapz_datetime(dask, which_datetime):
        rs = np.random.RandomState(42)
        if which_datetime == 'np':
            coord = np.array(
                ['2004-07-13', '2006-01-13', '2010-08-13', '2010-09-13',
                 '2010-10-11', '2010-12-13', '2011-02-13', '2012-08-13'],
                dtype='datetime64')
        else:
            if not has_cftime:
                pytest.skip('Test requires cftime.')
>           coord = xr.cftime_range('2000', periods=8, freq='2D')

xarray/tests/test_dataset.py:5252: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
xarray/coding/cftime_offsets.py:955: in cftime_range
    start = to_cftime_datetime(start, calendar)
xarray/coding/cftime_offsets.py:678: in to_cftime_datetime
    date, _ = _parse_iso8601_with_reso(get_date_type(calendar),
xarray/coding/cftimeindex.py:114: in _parse_iso8601_with_reso
    return default.replace(**replace), resolution
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

>   ???
E   ValueError: Replacing the dayofyr or dayofwk of a datetime is not supported.

src/cftime/_cftime.pyx:1315: ValueError
______________________ test_trapz_datetime[cftime-False] _______________________

dask = False, which_datetime = 'cftime'

    @pytest.mark.parametrize('dask', [True, False])
    @pytest.mark.parametrize('which_datetime', ['np', 'cftime'])
    def test_trapz_datetime(dask, which_datetime):
        rs = np.random.RandomState(42)
        if which_datetime == 'np':
            coord = np.array(
                ['2004-07-13', '2006-01-13', '2010-08-13', '2010-09-13',
                 '2010-10-11', '2010-12-13', '2011-02-13', '2012-08-13'],
                dtype='datetime64')
        else:
            if not has_cftime:
                pytest.skip('Test requires cftime.')
>           coord = xr.cftime_range('2000', periods=8, freq='2D')

xarray/tests/test_dataset.py:5252: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
xarray/coding/cftime_offsets.py:955: in cftime_range
    start = to_cftime_datetime(start, calendar)
xarray/coding/cftime_offsets.py:678: in to_cftime_datetime
    date, _ = _parse_iso8601_with_reso(get_date_type(calendar),
xarray/coding/cftimeindex.py:114: in _parse_iso8601_with_reso
    return default.replace(**replace), resolution
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

>   ???
E   ValueError: Replacing the dayofyr or dayofwk of a datetime is not supported.

src/cftime/_cftime.pyx:1315: ValueError
=============================== warnings summary ===============================
xarray/core/dask_array_ops.py:11
xarray/core/dask_array_ops.py:11
  /testbed/xarray/core/dask_array_ops.py:11: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(dask.__version__) <= LooseVersion('0.18.2'):

xarray/core/npcompat.py:135
xarray/core/npcompat.py:135
  /testbed/xarray/core/npcompat.py:135: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(np.__version__) >= LooseVersion('1.13'):

xarray/core/dask_array_compat.py:43
xarray/core/dask_array_compat.py:43
  /testbed/xarray/core/dask_array_compat.py:43: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(dask_version) > LooseVersion('0.19.2'):

xarray/plot/utils.py:17
xarray/plot/utils.py:17
  /testbed/xarray/plot/utils.py:17: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(nc_time_axis.__version__) < LooseVersion('1.2.0'):

xarray/core/pdcompat.py:46
  /testbed/xarray/core/pdcompat.py:46: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(pd.__version__) < '0.25.0':

../opt/miniconda3/envs/testbed/lib/python3.10/site-packages/setuptools/_distutils/version.py:345: 2 warnings
xarray/tests/test_variable.py: 101 warnings
xarray/tests/test_dataarray.py: 78 warnings
xarray/tests/test_dataset.py: 53 warnings
  /opt/miniconda3/envs/testbed/lib/python3.10/site-packages/setuptools/_distutils/version.py:345: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    other = LooseVersion(other)

xarray/tests/__init__.py:57: 17 warnings
xarray/tests/test_dataarray.py: 2 warnings
xarray/tests/test_dataset.py: 1 warning
  /testbed/xarray/tests/__init__.py:57: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    return version.LooseVersion(vstring)

xarray/tests/test_variable.py: 12 warnings
xarray/tests/test_dataarray.py: 12 warnings
xarray/tests/test_dataset.py: 63 warnings
  /testbed/xarray/core/variable.py:1596: DeprecationWarning: the `interpolation=` argument to nanpercentile was renamed to `method=`, which has additional options.
  Users of the modes 'nearest', 'lower', 'higher', or 'midpoint' are encouraged to review the method they used. (Deprecated NumPy 1.22)
    qs = np.nanpercentile(self.data, q * 100., axis=axis,

xarray/tests/test_variable.py: 99 warnings
xarray/tests/test_dataarray.py: 61 warnings
xarray/tests/test_dataset.py: 45 warnings
  /testbed/xarray/core/variable.py:900: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(dask.__version__) > '1.2.2':

xarray/tests/test_variable.py::TestVariableWithDask::test_eq_all_dtypes
  /opt/miniconda3/envs/testbed/lib/python3.10/site-packages/dask/core.py:119: FutureWarning: elementwise comparison failed; returning scalar instead, but in the future will perform elementwise comparison
    return func(*(_execute_task(a, cache) for a in args))

xarray/tests/test_variable.py::TestVariableWithDask::test_equals_all_dtypes
  /testbed/xarray/tests/test_variable.py:1810: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if '0.18.2' <= LooseVersion(dask.__version__) < '0.19.1':

xarray/tests/test_variable.py::test_raise_no_warning_for_nan_in_binary_ops
xarray/tests/test_dataarray.py::test_raise_no_warning_for_nan_in_binary_ops
xarray/tests/test_dataset.py::TestDataset::test_reindex_warning
xarray/tests/test_dataset.py::test_raise_no_warning_for_nan_in_binary_ops
  /opt/miniconda3/envs/testbed/lib/python3.10/site-packages/_pytest/python.py:194: PytestRemovedIn8Warning: Passing None has been deprecated.
  See https://docs.pytest.org/en/latest/how-to/capture-warnings.html#additional-use-cases-of-warnings-in-tests for alternatives in common use cases.
    result = testfunction(**testargs)

xarray/tests/test_dataarray.py: 77 warnings
xarray/tests/test_dataset.py: 404 warnings
  /testbed/xarray/core/formatting.py:147: DeprecationWarning: `np.float` is a deprecated alias for the builtin `float`. To silence this warning, use `float` by itself. Doing this will not modify any behavior and is safe. If you specifically wanted the numpy scalar type, use `np.float64` here.
  Deprecated in NumPy 1.20; for more details and guidance: https://numpy.org/devdocs/release/1.20.0-notes.html#deprecations
    elif isinstance(x, (float, np.float)):

xarray/tests/test_dataarray.py: 5 warnings
xarray/tests/test_dataset.py: 6 warnings
  /testbed/xarray/core/alignment.py:138: FutureWarning: Index.__and__ operating as a set operation is deprecated, in the future this will be a logical operation matching Series.__and__.  Use index.intersection(other) instead.
    index = joiner(matching_indexes)

xarray/tests/test_dataarray.py: 34 warnings
xarray/tests/test_dataset.py: 30 warnings
  /testbed/xarray/core/dataset.py:2897: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(pd.__version__) < LooseVersion('0.19.0'):

xarray/tests/test_dataarray.py: 10 warnings
xarray/tests/test_dataset.py: 7 warnings
  /testbed/xarray/core/dataset.py:3073: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(pd.__version__) >= "0.20":

xarray/tests/test_dataarray.py: 14 warnings
xarray/tests/test_dataset.py: 19 warnings
  /testbed/xarray/core/alignment.py:138: FutureWarning: Index.__or__ operating as a set operation is deprecated, in the future this will be a logical operation matching Series.__or__.  Use index.union(other) instead.
    index = joiner(matching_indexes)

xarray/tests/test_dataarray.py::TestDataArray::test_reindex_regressions
  /testbed/xarray/tests/test_dataarray.py:1306: DeprecationWarning: `np.complex` is a deprecated alias for the builtin `complex`. To silence this warning, use `complex` by itself. Doing this will not modify any behavior and is safe. If you specifically wanted the numpy scalar type, use `np.complex128` here.
  Deprecated in NumPy 1.20; for more details and guidance: https://numpy.org/devdocs/release/1.20.0-notes.html#deprecations
    x = np.array([1, 2, 3], dtype=np.complex)

xarray/tests/test_dataarray.py::TestDataArray::test_stack_unstack
  /testbed/xarray/tests/test_dataarray.py:1792: FutureWarning: pandas.Int64Index is deprecated and will be removed from pandas in a future version. Use pandas.Index with the appropriate dtype instead.
    b = pd.MultiIndex(levels=[pd.Int64Index([]), pd.Int64Index([0])],

xarray/tests/test_dataarray.py::TestDataArray::test_stack_unstack
  /opt/miniconda3/envs/testbed/lib/python3.10/site-packages/pandas/util/__init__.py:16: FutureWarning: pandas.util.testing is deprecated. Use the functions in the public API at pandas.testing instead.
    import pandas.util.testing

xarray/tests/test_dataarray.py: 9 warnings
xarray/tests/test_dataset.py: 5 warnings
  /testbed/xarray/core/groupby.py:153: FutureWarning: is_monotonic is deprecated and will be removed in a future version. Use is_monotonic_increasing instead.
    return index.is_unique and index.is_monotonic

xarray/tests/test_dataarray.py::TestDataArray::test_groupby_bins_sort
  /testbed/xarray/tests/test_dataarray.py:2483: FutureWarning: is_monotonic is deprecated and will be removed in a future version. Use is_monotonic_increasing instead.
    assert binned_mean.to_index().is_monotonic

xarray/tests/test_dataarray.py: 41 warnings
xarray/tests/test_dataset.py: 10 warnings
  /testbed/xarray/core/common.py:840: FutureWarning: 'base' in .resample() and in Grouper() is deprecated.
  The new arguments that you should use are 'offset' or 'origin'.
  
  >>> df.resample(freq="3s", base=2)
  
  becomes:
  
  >>> df.resample(freq="3s", offset="2s")
  
    grouper = pd.Grouper(freq=freq, closed=closed, label=label,

xarray/tests/test_dataarray.py: 40 warnings
xarray/tests/test_dataset.py: 10 warnings
  /testbed/xarray/core/groupby.py:264: FutureWarning: is_monotonic is deprecated and will be removed in a future version. Use is_monotonic_increasing instead.
    if not index.is_monotonic:

xarray/tests/test_dataarray.py::TestDataArray::test_resample
xarray/tests/test_dataset.py::TestDataset::test_resample_loffset
  /testbed/xarray/core/common.py:840: FutureWarning: 'loffset' in .resample() and in Grouper() is deprecated.
  
  >>> df.resample(freq="3s", loffset="8H")
  
  becomes:
  
  >>> from pandas.tseries.frequencies import to_offset
  >>> df = df.resample(freq="3s").mean()
  >>> df.index = df.index.to_timestamp() + to_offset("8H")
  
    grouper = pd.Grouper(freq=freq, closed=closed, label=label,

xarray/tests/test_dataarray.py::TestDataArray::test_resample
  /testbed/xarray/tests/test_dataarray.py:2497: FutureWarning: 'loffset' in .resample() and in Grouper() is deprecated.
  
  >>> df.resample(freq="3s", loffset="8H")
  
  becomes:
  
  >>> from pandas.tseries.frequencies import to_offset
  >>> df = df.resample(freq="3s").mean()
  >>> df.index = df.index.to_timestamp() + to_offset("8H")
  
    expected = DataArray(array.to_series().resample('24H', loffset='-12H')

xarray/tests/test_dataarray.py::TestDataArray::test_resample_drop_nondim_coords
xarray/tests/test_dataarray.py::TestDataArray::test_upsample_interpolate
xarray/tests/test_dataarray.py::TestDataArray::test_upsample_interpolate
xarray/tests/test_dataarray.py::TestDataArray::test_upsample_interpolate_bug_2197
xarray/tests/test_dataarray.py::TestDataArray::test_upsample_interpolate_regression_1605
xarray/tests/test_dataarray.py::TestDataArray::test_upsample_interpolate_dask
xarray/tests/test_dataarray.py::TestDataArray::test_upsample_interpolate_dask
xarray/tests/test_dataarray.py::TestDataArray::test_upsample_interpolate_dask
xarray/tests/test_dataset.py::TestDataset::test_resample_drop_nondim_coords
  /testbed/xarray/core/missing.py:380: FutureWarning: Passing method to DatetimeIndex.get_loc is deprecated and will raise in a future version. Use index.get_indexer([item], method=...) instead.
    imin = index.get_loc(np.min(new_x.values), method='nearest')

xarray/tests/test_dataarray.py::TestDataArray::test_resample_drop_nondim_coords
xarray/tests/test_dataarray.py::TestDataArray::test_upsample_interpolate
xarray/tests/test_dataarray.py::TestDataArray::test_upsample_interpolate
xarray/tests/test_dataarray.py::TestDataArray::test_upsample_interpolate_bug_2197
xarray/tests/test_dataarray.py::TestDataArray::test_upsample_interpolate_regression_1605
xarray/tests/test_dataarray.py::TestDataArray::test_upsample_interpolate_dask
xarray/tests/test_dataarray.py::TestDataArray::test_upsample_interpolate_dask
xarray/tests/test_dataarray.py::TestDataArray::test_upsample_interpolate_dask
xarray/tests/test_dataset.py::TestDataset::test_resample_drop_nondim_coords
  /testbed/xarray/core/missing.py:381: FutureWarning: Passing method to DatetimeIndex.get_loc is deprecated and will raise in a future version. Use index.get_indexer([item], method=...) instead.
    imax = index.get_loc(np.max(new_x.values), method='nearest')

xarray/tests/test_dataarray.py::TestDataArray::test_upsample
  /testbed/xarray/tests/test_dataarray.py:2630: FutureWarning: pad is deprecated and will be removed in a future version. Use ffill instead.
    expected = DataArray(array.to_series().resample('3H').pad())

xarray/tests/test_dataarray.py::TestDataArray::test_to_and_from_empty_series
  /testbed/xarray/tests/test_dataarray.py:3083: FutureWarning: The default dtype for empty Series will be 'object' instead of 'float64' in a future version. Specify a dtype explicitly to silence this warning.
    expected = pd.Series([])

xarray/tests/test_dataarray.py::TestDataArray::test_to_and_from_cdms2_classic
xarray/tests/test_dataarray.py::TestIrisConversion::test_to_and_from_iris
xarray/tests/test_dataarray.py::TestIrisConversion::test_to_and_from_iris
xarray/tests/test_dataarray.py::TestIrisConversion::test_to_and_from_iris_dask
xarray/tests/test_dataarray.py::TestIrisConversion::test_to_and_from_iris_dask
  /testbed/xarray/coding/times.py:212: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if LooseVersion(pd.__version__) < '0.25.0':

xarray/tests/test_dataarray.py::TestDataArray::test_to_and_from_cdms2_sgrid
xarray/tests/test_dataarray.py::TestDataArray::test_to_and_from_cdms2_sgrid
xarray/tests/test_dataarray.py::TestDataArray::test_to_and_from_cdms2_sgrid
xarray/tests/test_dataarray.py::TestDataArray::test_to_and_from_cdms2_sgrid
  /opt/miniconda3/envs/testbed/lib/python3.10/site-packages/numpy/ma/core.py:7939: DeprecationWarning: elementwise comparison failed; this will raise an error in the future.
    if not np.all(xinf == filled(np.isinf(y), False)):

xarray/tests/test_dataarray.py: 1952 warnings
xarray/tests/test_dataset.py: 5320 warnings
  /testbed/xarray/core/rolling.py:75: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    (LooseVersion(bottleneck.__version__) < LooseVersion('1.0'))):

xarray/tests/test_dataarray.py: 386 warnings
xarray/tests/test_dataset.py: 1016 warnings
  /testbed/xarray/core/rolling.py:322: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    if (LooseVersion(np.__version__) < LooseVersion('1.13') and

xarray/tests/test_dataset.py::TestDataset::test_constructor_pandas_single
  /testbed/xarray/core/merge.py:321: FutureWarning: iteritems is deprecated and will be removed in a future version. Use .items instead.
    obj = OrderedDict(obj.iteritems())

xarray/tests/test_dataset.py::TestDataset::test_sel_method
xarray/tests/test_dataset.py::TestDataset::test_sel_method
xarray/tests/test_dataset.py::TestDataset::test_sel_method
  /testbed/xarray/core/indexing.py:108: FutureWarning: Passing method to Float64Index.get_loc is deprecated and will raise in a future version. Use index.get_indexer([item], method=...) instead.
    return index.get_loc(label, **kwargs)

xarray/tests/test_dataset.py::TestDataset::test_resample_loffset
  /testbed/xarray/tests/test_dataset.py:3226: FutureWarning: 'loffset' in .resample() and in Grouper() is deprecated.
  
  >>> df.resample(freq="3s", loffset="8H")
  
  becomes:
  
  >>> from pandas.tseries.frequencies import to_offset
  >>> df = df.resample(freq="3s").mean()
  >>> df.index = df.index.to_timestamp() + to_offset("8H")
  
    expected = xr.DataArray(ds.bar.to_series()

xarray/tests/test_dataset.py::TestDataset::test_sortby
xarray/tests/test_dataset.py::TestDataset::test_sortby
xarray/tests/test_dataset.py::TestDataset::test_sortby
xarray/tests/test_dataset.py::TestDataset::test_sortby
xarray/tests/test_dataset.py::TestDataset::test_sortby
xarray/tests/test_dataset.py::TestDataset::test_sortby
xarray/tests/test_dataset.py::TestDataset::test_sortby
xarray/tests/test_dataset.py::TestDataset::test_sortby
  /testbed/xarray/core/dataset.py:4390: DeprecationWarning: distutils Version classes are deprecated. Use packaging.version instead.
    and LooseVersion(np.__version__) < LooseVersion('1.11.0')):

xarray/tests/test_dataset.py::test_coarsen_coords[1-True]
xarray/tests/test_dataset.py::test_coarsen_coords[1-False]
  /testbed/xarray/tests/test_dataset.py:4950: UserWarning: Parsing dates in DD/MM/YYYY format when dayfirst=False (the default) was specified. This may lead to inconsistently parsed dates! Specify a format to ensure consistent parsing.
    coords={'time': pd.date_range('15/12/1999', periods=364)})

-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
=========================== short test summary info ============================
FAILED xarray/tests/test_dataset.py::TestDataset::test_expand_dims_error - As...
FAILED xarray/tests/test_dataset.py::TestDataset::test_expand_dims_kwargs_python36plus
FAILED xarray/tests/test_dataset.py::test_coarsen_coords_cftime - ValueError:...
FAILED xarray/tests/test_dataset.py::test_differentiate_cftime[True] - ValueE...
FAILED xarray/tests/test_dataset.py::test_differentiate_cftime[False] - Value...
FAILED xarray/tests/test_dataset.py::test_trapz_datetime[cftime-True] - Value...
FAILED xarray/tests/test_dataset.py::test_trapz_datetime[cftime-False] - Valu...
7 failed, 1729 passed, 19 skipped, 11 xfailed, 4 xpassed, 10007 warnings in 33.30s

the Check fails on the tree as the run found it too (baseline-check.log), and this change adds no failing test to it: it passes
scope: xarray/core/indexing.py xarray/core/variable.py xarray/tests/test_variable.py xarray/tests/test_dataarray.py xarray/tests/test_dataset.py
changed: xarray/core/variable.py +2 -1
changed: xarray/tests/test_dataarray.py +11 -1
changed: xarray/tests/test_dataset.py +10 -0
changed: xarray/tests/test_variable.py +8 -0
```

### `test-status.txt`

```
0
```

### `untracked-before.txt`

```
.memdoor/.gitignore
.memdoor/workflows/single/README.md
.memdoor/workflows/single/steps/do.yaml
.memdoor/workflows/team-solve/README.md
.memdoor/workflows/team-solve/changes.sh
.memdoor/workflows/team-solve/check-samples.sh
.memdoor/workflows/team-solve/check.sh
.memdoor/workflows/team-solve/done.sh
.memdoor/workflows/team-solve/failures.sh
.memdoor/workflows/team-solve/sample/task.md
.memdoor/workflows/team-solve/sample/tests/1.in
.memdoor/workflows/team-solve/sample/tests/1.out
.memdoor/workflows/team-solve/sample/tests/2.in
.memdoor/workflows/team-solve/sample/tests/2.out
.memdoor/workflows/team-solve/sample/tests/3.in
.memdoor/workflows/team-solve/sample/tests/3.out
.memdoor/workflows/team-solve/sample/tests/4.in
.memdoor/workflows/team-solve/sample/tests/4.out
.memdoor/workflows/team-solve/sample/tests/5.in
.memdoor/workflows/team-solve/sample/tests/5.out
.memdoor/workflows/team-solve/scope.sh
.memdoor/workflows/team-solve/settle.sh
.memdoor/workflows/team-solve/snapshot.sh
.memdoor/workflows/team-solve/steps/baseline.yaml
.memdoor/workflows/team-solve/steps/context.yaml
.memdoor/workflows/team-solve/steps/direct.yaml
.memdoor/workflows/team-solve/steps/ideate.yaml
.memdoor/workflows/team-solve/steps/judge.yaml
.memdoor/workflows/team-solve/steps/keep.yaml
.memdoor/workflows/team-solve/steps/outline.yaml
.memdoor/workflows/team-solve/steps/plan.yaml
.memdoor/workflows/team-solve/steps/problem.yaml
.memdoor/workflows/team-solve/steps/recheck.yaml
.memdoor/workflows/team-solve/steps/repair.yaml
.memdoor/workflows/team-solve/steps/review.yaml
.memdoor/workflows/team-solve/steps/settle.yaml
.memdoor/workflows/team-solve/steps/solve.yaml
.memdoor/workflows/team-solve/steps/test-0.yaml
.memdoor/workflows/team-solve/steps/test.yaml
.memdoor/workflows/team-solve/steps/verify.yaml
.memdoor/workflows/team-solve/task.sh
.memdoor/workflows/team-solve/task.template.md
.memdoor/workflows/team-solve/verdict.sh
```
