# astropy__astropy-8707 — memdoor team-solve

Model: deepseek/deepseek-v4.1-flash via OpenRouter. Result line: `wf=0 198s 115 lines cost=0.012231 in=646926 cached=489472 out=17022 calls=31`

The agent received only the instance's `problem_statement`, in a container built from the instance's SWE-bench image, with network access to openrouter.ai only.

## Agent sessions, in order

### Step `direct` (agent)

**user**

```
Workflow team-solve, task direct.

Header.fromstring does not accept Python 3 bytes
According to [the docs](http://docs.astropy.org/en/stable/_modules/astropy/io/fits/header.html#Header.fromstring), the method `Header.fromstring` "...creates an HDU header from a byte string containing the entire header data."

By "byte string" here it really means the `str` type which on Python 2 could be raw binary data, but on Python 3 explicitly is not.   In fact it does work on Python 3's unicode `str`s, but here it assumes that the data can be ASCII-encoded.

Its counterpart, `Header.fromfile` will work with files opened in text or binary mode.  So probably the simplest solution for now (as opposed to adding new methods or something like that) is to change `Header.fromstring` to accept unicode or bytes string types.

`Card.fromstring` likely needs a similar treatment.


Do not commit, check out, reset or stash: the tree's HEAD stays where it is. Write what the task asks for as soon as you have a first version, then improve it: a turn that ends without it has done nothing. Keep no rule with the notes tool (it writes the project's AGENTS.md), and leave .memdoor/ alone.

Your answer is kept as this task's result; the tasks after it read it.
```

**assistant → tool `bash`**

```json
{
  "command": "ls && git status --short | head -50"
}
```

**assistant → tool `locate`**

```json
{
  "query": "Header.fromstring and Card.fromstring implementation in astropy io fits"
}
```

**tool result**

```
CHANGES.rst
CITATION
CODE_OF_CONDUCT.md
CONTRIBUTING.md
GOVERNANCE.md
LICENSE.rst
MANIFEST.in
README.rst
__pycache__
ah_bootstrap.py
appveyor.yml
astropy
astropy.egg-info
astropy_helpers
build
cextern
conftest.py
docs
examples
licenses
pip-requirements
setup.cfg
setup.py
static
?? .memdoor/
```

**tool result**

```
Where "Header.fromstring and Card.fromstring implementation in astropy io fits" lives (judged: 19 of 40 sections kept), most relevant first:
1. astropy/io/fits/card.py:526-559  p=0.95
2. astropy/io/fits/header.py:345-380  p=0.94
3. astropy/io/fits/hdu/base.py:234-272  p=0.70
4. astropy/io/fits/tests/test_header.py:1855-1888  p=0.57
5. docs/io/fits/usage/verification.rst:239-278  p=0.57
6. docs/io/fits/usage/headers.rst:270-300  p=0.55

== astropy/io/fits/card.py:526-559 (p=0.95)
  526      @property
  527      def is_blank(self):
  528          """
  529          `True` if the card is completely blank--that is, it has no keyword,
  530          value, or comment.  It appears in the header as 80 spaces.
  531  
  532          Returns `False` otherwise.
  533          """
  534  
  535          if not self._verified:
  536              # The card image has not been parsed yet; compare directly with the
  537              # string representation of a blank card
  538              return self._image == BLANK_CARD
  539  
  540          # If the keyword, value, and comment are all empty (for self.value
  541          # explicitly check that it is a string value, since a blank value is
  542          # returned as '')
  543          return (not self.keyword and
  544                  (isinstance(self.value, str) and not self.value) and
  545                  not self.comment)
  546  
  547      @classmethod
  548      def fromstring(cls, image):
  549          """
  550          Construct a `Card` object from a (raw) string. It will pad the string
  551          if it is not the length of a card image (80 columns).  If the card
  552          image is longer than 80 columns, assume it contains ``CONTINUE``
  553          card(s).
  554          """
  555  
  556          card = cls()
  557          card._image = _pad(image)
  558          card._verified = False
  559          return card

== astropy/io/fits/header.py:345-380 (p=0.94)
  345          Returns
  346          -------
  347          header
  348              A new `Header` instance.
  349          """
  350  
  351          cards = []
  352  
  353          # If the card separator contains characters that may validly appear in
  354          # a card, the only way to unambiguously distinguish between cards is to
  355          # require that they be Card.length long.  However, if the separator
  356          # contains non-valid characters (namely \n) the cards may be split
  357          # immediately at the separator
  358          require_full_cardlength = set(sep).issubset(VALID_HEADER_CHARS)
  359  
  360          # Split the header into individual cards
  361          idx = 0
  362          image = []
  363  
  364          while idx < len(data):
  365              if require_full_cardlength:
  366                  end_idx = idx + Card.length
  367              else:
  368                  try:
  369                      end_idx = data.index(sep, idx)
  370                  except ValueError:
  371                      end_idx = len(data)
  372  
  373              next_image = data[idx:end_idx]
  374              idx = end_idx + len(sep)
  375  
  376              if image:
  377                  if next_image[:8] == 'CONTINUE':
  378                      image.append(next_image)
  379                      continue
  380                  cards.append(Card.fromstring(''.join(image)))

== astropy/io/fits/header.py:309-343 (p=0.93)
  309      @property
  310      def _modified(self):
  311          """
  312          Whether or not the header has been modified; this is a property so that
  313          it can also check each card for modifications--cards may have been
  314          modified directly without the header containing it otherwise knowing.
  315          """
  316  
  317          modified_cards = any(c._modified for c in self._cards)
  318          if modified_cards:
  319              # If any cards were modified then by definition the header was
  320              # modified
  321              self.__dict__['_modified'] = True
  322  
  323          return self.__dict__['_modified']
  324  
  325      @_modified.setter
  326      def _modified(self, val):
  327          self.__dict__['_modified'] = val
  328  
  329      @classmethod
  330      def fromstring(cls, data, sep=''):
  331          """
  332          Creates an HDU header from a byte string containing the entire header
  333          data.
  334  
  335          Parameters
  336          ----------
  337          data : str
  338             String containing the entire header.
  339  
  340          sep : str, optional
  341              The string separating cards from each other, such as a newline.  By
  342              default there is no card separator (as is the case in a raw FITS
  343              file).

read_file or jread a file to see more; locate again with file set to rank one file's sections.
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '1,120p' astropy/io/fits/card.py; echo ====; sed -n '329,410p' astropy/io/fits/header.py; echo ====; grep -n \"def fromfile\\|def fromstring\\|_pad\\|decode\\|encode\" astropy/io/fits/header.py astropy/io/fits/card.py | head -60"
}
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"fromstring\" astropy/io/fits/tests/test_header.py astropy/io/fits/tests/test_card.py | head -50; echo ====; sed -n '1840,1900p' astropy/io/fits/tests/test_header.py"
}
```

**tool result**

```
# Licensed under a 3-clause BSD style license - see PYFITS.rst

import re
import warnings

import numpy as np

from .util import _str_to_num, _is_int, translate, _words_group
from .verify import _Verify, _ErrList, VerifyError, VerifyWarning

from . import conf
from astropy.utils.exceptions import AstropyUserWarning


__all__ = ['Card', 'Undefined']


FIX_FP_TABLE = str.maketrans('de', 'DE')
FIX_FP_TABLE2 = str.maketrans('dD', 'eE')


CARD_LENGTH = 80
BLANK_CARD = ' ' * CARD_LENGTH
KEYWORD_LENGTH = 8  # The max length for FITS-standard keywords

VALUE_INDICATOR = '= '  # The standard FITS value indicator
VALUE_INDICATOR_LEN = len(VALUE_INDICATOR)
HIERARCH_VALUE_INDICATOR = '='  # HIERARCH cards may use a shortened indicator


class Undefined:
    """Undefined value."""

    def __init__(self):
        # This __init__ is required to be here for Sphinx documentation
        pass


UNDEFINED = Undefined()


class Card(_Verify):

    length = CARD_LENGTH
    """The length of a Card image; should always be 80 for valid FITS files."""

    # String for a FITS standard compliant (FSC) keyword.
    _keywd_FSC_RE = re.compile(r'^[A-Z0-9_-]{0,%d}$' % KEYWORD_LENGTH)
    # This will match any printable ASCII character excluding '='
    _keywd_hierarch_RE = re.compile(r'^(?:HIERARCH +)?(?:^[ -<>-~]+ ?)+$',
                                    re.I)

    # A number sub-string, either an integer or a float in fixed or
    # scientific notation.  One for FSC and one for non-FSC (NFSC) format:
    # NFSC allows lower case of DE for exponent, allows space between sign,
    # digits, exponent sign, and exponents
    _digits_FSC = r'(\.\d+|\d+(\.\d*)?)([DE][+-]?\d+)?'
    _digits_NFSC = r'(\.\d+|\d+(\.\d*)?) *([deDE] *[+-]? *\d+)?'
    _numr_FSC = r'[+-]?' + _digits_FSC
    _numr_NFSC = r'[+-]? *' + _digits_NFSC

    # This regex helps delete leading zeros from numbers, otherwise
    # Python might evaluate them as octal values (this is not-greedy, however,
    # so it may not strip leading zeros from a float, which is fine)
    _number_FSC_RE = re.compile(r'(?P<sign>[+-])?0*?(?P<digt>{})'.format(
            _digits_FSC))
    _number_NFSC_RE = re.compile(r'(?P<sign>[+-])? *0*?(?P<digt>{})'.format(
            _digits_NFSC))

    # FSC commentary card string which must contain printable ASCII characters.
    # Note: \Z matches the end of the string without allowing newlines
    _ascii_text_re = re.compile(r'[ -~]*\Z')

    # Checks for a valid value/comment string.  It returns a match object
    # for a valid value/comment string.
    # The valu group will return a match if a FITS string, boolean,
    # number, or complex value is found, otherwise it will return
    # None, meaning the keyword is undefined.  The comment field will
    # return a match if the comment separator is found, though the
    # comment maybe an empty string.
    _value_FSC_RE = re.compile(
        r'(?P<valu_field> *'
            r'(?P<valu>'

                #  The <strg> regex is not correct for all cases, but
                #  it comes pretty darn close.  It appears to find the
                #  end of a string rather well, but will accept
                #  strings with an odd number of single quotes,
                #  instead of issuing an error.  The FITS standard
                #  appears vague on this issue and only states that a
                #  string should not end with two single quotes,
                #  whereas it should not end with an even number of
                #  quotes to be precise.
                #
                #  Note that a non-greedy match is done for a string,
                #  since a greedy match will find a single-quote after
                #  the comment separator resulting in an incorrect
                #  match.
                r'\'(?P<strg>([ -~]+?|\'\'|)) *?\'(?=$|/| )|'
                r'(?P<bool>[FT])|'
                r'(?P<numr>' + _numr_FSC + r')|'
                r'(?P<cplx>\( *'
                    r'(?P<real>' + _numr_FSC + r') *, *'
                    r'(?P<imag>' + _numr_FSC + r') *\))'
            r')? *)'
        r'(?P<comm_field>'
            r'(?P<sepr>/ *)'
            r'(?P<comm>[!-~][ -~]*)?'
        r')?$')

    _value_NFSC_RE = re.compile(
        r'(?P<valu_field> *'
            r'(?P<valu>'
                r'\'(?P<strg>([ -~]+?|\'\'|) *?)\'(?=$|/| )|'
                r'(?P<bool>[FT])|'
                r'(?P<numr>' + _numr_NFSC + r')|'
                r'(?P<cplx>\( *'
                    r'(?P<real>' + _numr_NFSC + r') *, *'
                    r'(?P<imag>' + _numr_NFSC + r') *\))'
            r')? *)'
====
    @classmethod
    def fromstring(cls, data, sep=''):
        """
        Creates an HDU header from a byte string containing the entire header
        data.

        Parameters
        ----------
        data : str
           String containing the entire header.

        sep : str, optional
            The string separating cards from each other, such as a newline.  By
            default there is no card separator (as is the case in a raw FITS
            file).

        Returns
        -------
        header
            A new `Header` instance.
        """

        cards = []

        # If the card separator contains characters that may validly appear in
        # a card, the only way to unambiguously distinguish between cards is to
        # require that they be Card.length long.  However, if the separator
        # contains non-valid characters (namely \n) the cards may be split
        # immediately at the separator
        require_full_cardlength = set(sep).issubset(VALID_HEADER_CHARS)

        # Split the header into individual cards
        idx = 0
        image = []

        while idx < len(data):
            if require_full_cardlength:
                end_idx = idx + Card.length
            else:
                try:
                    end_idx = data.index(sep, idx)
                except ValueError:
                    end_idx = len(data)

            next_image = data[idx:end_idx]
            idx = end_idx + len(sep)

            if image:
                if next_image[:8] == 'CONTINUE':
                    image.append(next_image)
                    continue
                cards.append(Card.fromstring(''.join(image)))

            if require_full_cardlength:
                if next_image == END_CARD:
                    image = []
                    break
            else:
                if next_image.split(sep)[0].rstrip() == 'END':
                    image = []
                    break

            image = [next_image]

        # Add the last image that was found before the end, if any
        if image:
            cards.append(Card.fromstring(''.join(image)))

        return cls._fromcards(cards)

    @classmethod
    def fromfile(cls, fileobj, sep='', endcard=True, padding=True):
        """
        Similar to :meth:`Header.fromstring`, but reads the header string from
        a given file-like object or filename.

        Parameters
        ----------
        fileobj : str, file-like
            A filename or an open file-like object from which a FITS header is
            to be read.  For open file handles the file pointer must be at the
            beginning of the header.
====
astropy/io/fits/header.py:9:from .card import Card, _pad, KEYWORD_LENGTH, UNDEFINED
astropy/io/fits/header.py:11:from .util import encode_ascii, decode_ascii, fileobj_closed, fileobj_is_binary
astropy/io/fits/header.py:27:HEADER_END_RE = re.compile(encode_ascii(
astropy/io/fits/header.py:330:    def fromstring(cls, data, sep=''):
astropy/io/fits/header.py:400:    def fromfile(cls, fileobj, sep='', endcard=True, padding=True):
astropy/io/fits/header.py:504:            block = encode_ascii(block)
astropy/io/fits/header.py:515:            read_blocks.append(decode_ascii(block))
astropy/io/fits/header.py:531:                block = encode_ascii(block)
astropy/io/fits/header.py:539:        _check_padding(header_str, actual_block_size, is_eof,
astropy/io/fits/header.py:582:                block = (block[:offset] + encode_ascii(END_CARD) +
astropy/io/fits/header.py:629:            s += sep + _pad('END')
astropy/io/fits/header.py:631:            s += ' ' * _pad_length(len(s))
astropy/io/fits/header.py:693:                fileobj.write(blocks.encode('ascii'))
astropy/io/fits/header.py:2008:    def fromfile(cls, fileobj):
astropy/io/fits/header.py:2019:            _check_padding(header_str, BLOCK_SIZE, False)
astropy/io/fits/header.py:2211:def _pad_length(stringlen):
astropy/io/fits/header.py:2217:def _check_padding(header_str, block_size, is_eof, check_block_size=True):
astropy/io/fits/card.py:335:            # Allow str, but only if they can be decoded to ASCII text; note
astropy/io/fits/card.py:342:                text_value = value.decode('ascii')
astropy/io/fits/card.py:548:    def fromstring(cls, image):
astropy/io/fits/card.py:557:        card._image = _pad(image)
astropy/io/fits/card.py:1269:def _pad(input):
```

**tool result**

```
astropy/io/fits/tests/test_header.py:102:        c = fits.Card.fromstring('ABC     = F')
astropy/io/fits/tests/test_header.py:253:    def test_commentary_card_created_by_fromstring(self):
astropy/io/fits/tests/test_header.py:254:        # commentary card created by fromstring()
astropy/io/fits/tests/test_header.py:255:        c = fits.Card.fromstring(
astropy/io/fits/tests/test_header.py:264:        c = fits.Card.fromstring("HISTORY  (1, 2)")
astropy/io/fits/tests/test_header.py:270:        c = fits.Card.fromstring("HISTORY =   (1, 2)")
astropy/io/fits/tests/test_header.py:276:        c = fits.Card.fromstring(str(c))
astropy/io/fits/tests/test_header.py:287:        c = fits.Card.fromstring('ABC     = (8, 9)')
astropy/io/fits/tests/test_header.py:292:        c = fits.Card.fromstring('abc     = +  2.1   e + 12')
astropy/io/fits/tests/test_header.py:302:        c = fits.Card.fromstring(
astropy/io/fits/tests/test_header.py:312:        c = fits.Card.fromstring('ABC     =    ')
astropy/io/fits/tests/test_header.py:317:        c = fits.Card.fromstring('XYZ= 100')
astropy/io/fits/tests/test_header.py:331:        c = fits.Card.fromstring("HISTO       =   (1, 2)")
astropy/io/fits/tests/test_header.py:338:        c = fits.Card.fromstring("   HISTORY          (1, 2)")
astropy/io/fits/tests/test_header.py:345:        c = fits.Card.fromstring('ABC= a6')
astropy/io/fits/tests/test_header.py:357:        c = fits.Card.fromstring('ABC= a6')
astropy/io/fits/tests/test_header.py:464:    def test_long_string_value_via_fromstring(self, capsys):
astropy/io/fits/tests/test_header.py:465:        # long string value via fromstring() method
astropy/io/fits/tests/test_header.py:466:        c = fits.Card.fromstring(
astropy/io/fits/tests/test_header.py:485:        c = fits.Card.fromstring(
astropy/io/fits/tests/test_header.py:543:        c = fits.Card.fromstring("HIERARCH key.META_4='calFileVersion'")
astropy/io/fits/tests/test_header.py:557:        c = fits.Card.fromstring(
astropy/io/fits/tests/test_header.py:814:        header = fits.Header.fromstring(hstr, sep='\n')
astropy/io/fits/tests/test_header.py:1775:        h = fits.Header.fromstring(hstr, sep='\n')
astropy/io/fits/tests/test_header.py:1798:        h = fits.Header.fromstring(hstr, sep='\n')
astropy/io/fits/tests/test_header.py:1863:        c = fits.Card.fromstring("APERTURE= +0.000000000000E+000")
astropy/io/fits/tests/test_header.py:1866:        c = fits.Card.fromstring("APERTURE= 0.000000000000E+000")
astropy/io/fits/tests/test_header.py:1869:        c = fits.Card.fromstring("APERTURE= 017")
astropy/io/fits/tests/test_header.py:1899:        h.append(fits.Card.fromstring(fooimg))
astropy/io/fits/tests/test_header.py:1900:        h.append(fits.Card.fromstring(barimg))
astropy/io/fits/tests/test_header.py:2070:        c = fits.Card.fromstring("QUX     = 'Bar        '")
astropy/io/fits/tests/test_header.py:2128:        c1 = fits.Card.fromstring('CLFIND2D: contour = 0.30')
astropy/io/fits/tests/test_header.py:2129:        c2 = fits.Card.fromstring('Just some random text.')
astropy/io/fits/tests/test_header.py:2130:        c3 = fits.Card.fromstring('A' * 80)
astropy/io/fits/tests/test_header.py:2169:        c = fits.Card.fromstring('HIERARCH ESO DET CHIP PXSPACE = 5e6')
astropy/io/fits/tests/test_header.py:2325:            c = fits.Card.fromstring(card_image)
astropy/io/fits/tests/test_header.py:2361:        c = fits.Card.fromstring("DP1     = 'NAXIS: 2' / A comment")
astropy/io/fits/tests/test_header.py:2367:        c = fits.Card.fromstring("DP1     = 'NAXIS: 2.1'")
astropy/io/fits/tests/test_header.py:2372:        c = fits.Card.fromstring("DP1     = 'NAXIS: a'")
astropy/io/fits/tests/test_header.py:2414:        c = fits.Card.fromstring("DP1     = 'NAXIS: 2' / A comment")
astropy/io/fits/tests/test_header.py:2426:        c = fits.Card.fromstring("DP1     = 'NAXIS: 2' / A comment")
astropy/io/fits/tests/test_header.py:2518:        c = fits.Card.fromstring("DP1     = 'NAXIS: 2' / A comment")
astropy/io/fits/tests/test_header.py:2675:        c = fits.Card.fromstring(
astropy/io/fits/tests/tesgrep: astropy/io/fits/tests/test_card.py: No such file or directory
t_header.py:2698:        c1 = fits.Card.fromstring("FOO     = 'AXIS.1: 2'")
astropy/io/fits/tests/test_header.py:2699:        c2 = fits.Card.fromstring("FOO     = 'AXIS.2: 4'")
====
        hdul = fits.open(self.temp('test.fits'))
        with catch_warnings() as w:
            hdul.writeto(self.temp('temp.fits'), output_verify='warn')
        assert len(w) == 5
        # The first two warnings are just the headers to the actual warning
        # message (HDU 0, Card 4).  I'm still not sure things like that
        # should be output as separate warning messages, but that's
        # something to think about...
        msg = str(w[3].message)
        assert "(invalid value string: '5.0022221e-07')" in msg

    def test_leading_zeros(self):
        """
        Regression test for https://aeon.stsci.edu/ssb/trac/pyfits/ticket/137, part 2

        Ticket https://aeon.stsci.edu/ssb/trac/pyfits/ticket/137 also showed that in
        float values like 0.001 the leading zero was unnecessarily being
        stripped off when rewriting the header.  Though leading zeros should be
        removed from integer values to prevent misinterpretation as octal by
        python (for now Astropy will still maintain the leading zeros if now
        changes are made to the value, but will drop them if changes are made).
        """

        c = fits.Card.fromstring("APERTURE= +0.000000000000E+000")
        assert str(c) == _pad("APERTURE= +0.000000000000E+000")
        assert c.value == 0.0
        c = fits.Card.fromstring("APERTURE= 0.000000000000E+000")
        assert str(c) == _pad("APERTURE= 0.000000000000E+000")
        assert c.value == 0.0
        c = fits.Card.fromstring("APERTURE= 017")
        assert str(c) == _pad("APERTURE= 017")
        assert c.value == 17

    def test_assign_boolean(self):
        """
        Regression test for https://aeon.stsci.edu/ssb/trac/pyfits/ticket/123

        Tests assigning Python and Numpy boolean values to keyword values.
        """

        fooimg = _pad('FOO     =                    T')
        barimg = _pad('BAR     =                    F')
        h = fits.Header()
        h['FOO'] = True
        h['BAR'] = False
        assert h['FOO'] is True
        assert h['BAR'] is False
        assert str(h.cards['FOO']) == fooimg
        assert str(h.cards['BAR']) == barimg

        h = fits.Header()
        h['FOO'] = np.bool_(True)
        h['BAR'] = np.bool_(False)
        assert h['FOO'] is True
        assert h['BAR'] is False
        assert str(h.cards['FOO']) == fooimg
        assert str(h.cards['BAR']) == barimg

        h = fits.Header()
        h.append(fits.Card.fromstring(fooimg))
        h.append(fits.Card.fromstring(barimg))
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '410,550p' astropy/io/fits/header.py; echo ====; grep -n \"def encode_ascii\\|def decode_ascii\\|VALID_HEADER_CHARS\" -A20 astropy/io/fits/util.py astropy/io/fits/header.py | head -80; echo ====; sed -n '1255,1290p' astropy/io/fits/card.py"
}
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '300,370p' astropy/io/fits/card.py; echo ====; sed -n '1,40p' astropy/io/fits/header.py; echo ====; python -c \"import astropy; print(astropy.__version__)\""
}
```

**tool result**

```
            beginning of the header.

        sep : str, optional
            The string separating cards from each other, such as a newline.  By
            default there is no card separator (as is the case in a raw FITS
            file).

        endcard : bool, optional
            If True (the default) the header must end with an END card in order
            to be considered valid.  If an END card is not found an
            `OSError` is raised.

        padding : bool, optional
            If True (the default) the header will be required to be padded out
            to a multiple of 2880, the FITS header block size.  Otherwise any
            padding, or lack thereof, is ignored.

        Returns
        -------
        header
            A new `Header` instance.
        """

        close_file = False
        if isinstance(fileobj, str):
            # Open in text mode by default to support newline handling; if a
            # binary-mode file object is passed in, the user is on their own
            # with respect to newline handling
            fileobj = open(fileobj, 'r')
            close_file = True

        try:
            is_binary = fileobj_is_binary(fileobj)

            def block_iter(nbytes):
                while True:
                    data = fileobj.read(nbytes)

                    if data:
                        yield data
                    else:
                        break

            return cls._from_blocks(block_iter, is_binary, sep, endcard,
                                    padding)[1]
        finally:
            if close_file:
                fileobj.close()

    @classmethod
    def _fromcards(cls, cards):
        header = cls()
        for idx, card in enumerate(cards):
            header._cards.append(card)
            keyword = Card.normalize_keyword(card.keyword)
            header._keyword_indices[keyword].append(idx)
            if card.field_specifier is not None:
                header._rvkc_indices[card.rawkeyword].append(idx)

        header._modified = False
        return header

    @classmethod
    def _from_blocks(cls, block_iter, is_binary, sep, endcard, padding):
        """
        The meat of `Header.fromfile`; in a separate method so that
        `Header.fromfile` itself is just responsible for wrapping file
        handling.  Also used by `_BaseHDU.fromstring`.

        ``block_iter`` should be a callable which, given a block size n
        (typically 2880 bytes as used by the FITS standard) returns an iterator
        of byte strings of that block size.

        ``is_binary`` specifies whether the returned blocks are bytes or text

        Returns both the entire header *string*, and the `Header` object
        returned by Header.fromstring on that string.
        """

        actual_block_size = _block_size(sep)
        clen = Card.length + len(sep)

        blocks = block_iter(actual_block_size)

        # Read the first header block.
        try:
            block = next(blocks)
        except StopIteration:
            raise EOFError()

        if not is_binary:
            # TODO: There needs to be error handling at *this* level for
            # non-ASCII characters; maybe at this stage decoding latin-1 might
            # be safer
            block = encode_ascii(block)

        read_blocks = []
        is_eof = False
        end_found = False

        # continue reading header blocks until END card or EOF is reached
        while True:
            # find the END card
            end_found, block = cls._find_end_card(block, clen)

            read_blocks.append(decode_ascii(block))

            if end_found:
                break

            try:
                block = next(blocks)
            except StopIteration:
                is_eof = True
                break

            if not block:
                is_eof = True
                break

            if not is_binary:
                block = encode_ascii(block)

        if not end_found and is_eof and endcard:
            # TODO: Pass this error to validation framework as an ERROR,
            # rather than raising an exception
            raise OSError('Header missing END card.')

        header_str = ''.join(read_blocks)
        _check_padding(header_str, actual_block_size, is_eof,
                       check_block_size=padding)

        return header_str, cls.fromstring(header_str, sep=sep)

    @classmethod
    def _find_end_card(cls, block, card_len):
        """
        Utility method to search a header block for the END card and handle
        invalid END cards.

        This method can also returned a modified copy of the input header block
====
astropy/io/fits/util.py:262:def encode_ascii(s):
astropy/io/fits/util.py-263-    if isinstance(s, str):
astropy/io/fits/util.py-264-        return s.encode('ascii')
astropy/io/fits/util.py-265-    elif (isinstance(s, np.ndarray) and
astropy/io/fits/util.py-266-          issubclass(s.dtype.type, np.str_)):
astropy/io/fits/util.py-267-        ns = np.char.encode(s, 'ascii').view(type(s))
astropy/io/fits/util.py-268-        if ns.dtype.itemsize != s.dtype.itemsize / 4:
astropy/io/fits/util.py-269-            ns = ns.astype((np.bytes_, s.dtype.itemsize / 4))
astropy/io/fits/util.py-270-        return ns
astropy/io/fits/util.py-271-    elif (isinstance(s, np.ndarray) and
astropy/io/fits/util.py-272-          not issubclass(s.dtype.type, np.bytes_)):
astropy/io/fits/util.py-273-        raise TypeError('string operation on non-string array')
astropy/io/fits/util.py-274-    return s
astropy/io/fits/util.py-275-
astropy/io/fits/util.py-276-
astropy/io/fits/util.py:277:def decode_ascii(s):
astropy/io/fits/util.py-278-    if isinstance(s, bytes):
astropy/io/fits/util.py-279-        try:
astropy/io/fits/util.py-280-            return s.decode('ascii')
astropy/io/fits/util.py-281-        except UnicodeDecodeError:
astropy/io/fits/util.py-282-            warnings.warn('non-ASCII characters are present in the FITS '
astropy/io/fits/util.py-283-                          'file header and have been replaced by "?" '
astropy/io/fits/util.py-284-                          'characters', AstropyUserWarning)
astropy/io/fits/util.py-285-            s = s.decode('ascii', errors='replace')
astropy/io/fits/util.py-286-            return s.replace(u'\ufffd', '?')
astropy/io/fits/util.py-287-    elif (isinstance(s, np.ndarray) and
astropy/io/fits/util.py-288-          issubclass(s.dtype.type, np.bytes_)):
astropy/io/fits/util.py-289-        # np.char.encode/decode annoyingly don't preserve the type of the
astropy/io/fits/util.py-290-        # array, hence the view() call
astropy/io/fits/util.py-291-        # It also doesn't necessarily preserve widths of the strings,
astropy/io/fits/util.py-292-        # hence the astype()
astropy/io/fits/util.py-293-        if s.size == 0:
astropy/io/fits/util.py-294-            # Numpy apparently also has a bug that if a string array is
astropy/io/fits/util.py-295-            # empty calling np.char.decode on it returns an empty float64
astropy/io/fits/util.py-296-            # array wth
astropy/io/fits/util.py-297-            dt = s.dtype.str.replace('S', 'U')
--
astropy/io/fits/header.py:33:VALID_HEADER_CHARS = set(map(chr, range(0x20, 0x7F)))
astropy/io/fits/header.py-34-END_CARD = 'END' + ' ' * 77
astropy/io/fits/header.py-35-
astropy/io/fits/header.py-36-
astropy/io/fits/header.py-37-__doctest_skip__ = ['Header', 'Header.*']
astropy/io/fits/header.py-38-
astropy/io/fits/header.py-39-
astropy/io/fits/header.py-40-class Header:
astropy/io/fits/header.py-41-    """
astropy/io/fits/header.py-42-    FITS header class.  This class exposes both a dict-like interface and a
astropy/io/fits/header.py-43-    list-like interface to FITS headers.
astropy/io/fits/header.py-44-
astropy/io/fits/header.py-45-    The header may be indexed by keyword and, like a dict, the associated value
astropy/io/fits/header.py-46-    will be returned.  When the header contains cards with duplicate keywords,
astropy/io/fits/header.py-47-    only the value of the first card with the given keyword will be returned.
astropy/io/fits/header.py-48-    It is also possible to use a 2-tuple as the index in the form (keyword,
astropy/io/fits/header.py-49-    n)--this returns the n-th value with that keyword, in the case where there
astropy/io/fits/header.py-50-    are duplicate keywords.
astropy/io/fits/header.py-51-
astropy/io/fits/header.py-52-    For example::
astropy/io/fits/header.py-53-
--
astropy/io/fits/header.py:358:        require_full_cardlength = set(sep).issubset(VALID_HEADER_CHARS)
astropy/io/fits/header.py-359-
astropy/io/fits/header.py-360-        # Split the header into individual cards
astropy/io/fits/header.py-361-        idx = 0
astropy/io/fits/header.py-362-        image = []
astropy/io/fits/header.py-363-
astropy/io/fits/header.py-364-        while idx < len(data):
astropy/io/fits/header.py-365-            if require_full_cardlength:
astropy/io/fits/header.py-366-                end_idx = idx + Card.length
astropy/io/fits/header.py-367-            else:
astropy/io/fits/header.py-368-                try:
astropy/io/fits/header.py-369-                    end_idx = data.index(sep, idx)
astropy/io/fits/header.py-370-                except ValueError:
astropy/io/fits/header.py-371-                    end_idx = len(data)
astropy/io/fits/header.py-372-
astropy/io/fits/header.py-373-            next_image = data[idx:end_idx]
astropy/io/fits/header.py-374-            idx = end_idx + len(sep)
astropy/io/fits/header.py-375-
astropy/io/fits/header.py-376-            if image:
astropy/io/fits/header.py-377-                if next_image[:8] == 'CONTINUE':
astropy/io/fits/header.py-378-                    image.append(next_image)
====
    # Limit the value string to at most 20 characters.
    str_len = len(value_str)

    if str_len > 20:
        idx = value_str.find('E')

        if idx < 0:
            value_str = value_str[:20]
        else:
            value_str = value_str[:20 - (str_len - idx)] + value_str[idx:]

    return value_str


def _pad(input):
    """Pad blank space to the input string to be multiple of 80."""

    _len = len(input)
    if _len == Card.length:
        return input
    elif _len > Card.length:
        strlen = _len % Card.length
        if strlen == 0:
            return input
        else:
            return input + ' ' * (Card.length - strlen)

    # minimum length is 80
    else:
        strlen = _len % Card.length
        return input + ' ' * (Card.length - strlen)
```

**tool result**

```
            raise ValueError(
                'The value of invalid/unparseable cards cannot set.  Either '
                'delete this card from the header or replace it.')

        if value is None:
            value = UNDEFINED

        try:
            oldvalue = self.value
        except VerifyError:
            # probably a parsing error, falling back to the internal _value
            # which should be None. This may happen while calling _fix_value.
            oldvalue = self._value

        if oldvalue is None:
            oldvalue = UNDEFINED

        if not isinstance(value,
                          (str, int, float, complex, bool, Undefined,
                           np.floating, np.integer, np.complexfloating,
                           np.bool_)):
            raise ValueError('Illegal value: {!r}.'.format(value))

        if isinstance(value, float) and (np.isnan(value) or np.isinf(value)):
            raise ValueError("Floating point {!r} values are not allowed "
                             "in FITS headers.".format(value))

        elif isinstance(value, str):
            m = self._ascii_text_re.match(value)
            if not m:
                raise ValueError(
                    'FITS header values must contain standard printable ASCII '
                    'characters; {!r} contains characters not representable in '
                    'ASCII or non-printable characters.'.format(value))
        elif isinstance(value, bytes):
            # Allow str, but only if they can be decoded to ASCII text; note
            # this is not even allowed on Python 3 since the `bytes` type is
            # not included in `str`.  Presently we simply don't
            # allow bytes to be assigned to headers, as doing so would too
            # easily mask potential user error
            valid = True
            try:
                text_value = value.decode('ascii')
            except UnicodeDecodeError:
                valid = False
            else:
                # Check against the printable characters regexp as well
                m = self._ascii_text_re.match(text_value)
                valid = m is not None

            if not valid:
                raise ValueError(
                    'FITS header values must contain standard printable ASCII '
                    'characters; {!r} contains characters/bytes that do not '
                    'represent printable characters in ASCII.'.format(value))
        elif isinstance(value, np.bool_):
            value = bool(value)

        if (conf.strip_header_whitespace and
            (isinstance(oldvalue, str) and isinstance(value, str))):
            # Ignore extra whitespace when comparing the new value to the old
            different = oldvalue.rstrip() != value.rstrip()
        elif isinstance(oldvalue, bool) or isinstance(value, bool):
            different = oldvalue is not value
        else:
            different = (oldvalue != value or
                         not isinstance(value, type(oldvalue)))

        if different:
            self._value = value
            self._rawvalue = None
====
# Licensed under a 3-clause BSD style license - see PYFITS.rst

import collections
import copy
import itertools
import re
import warnings

from .card import Card, _pad, KEYWORD_LENGTH, UNDEFINED
from .file import _File
from .util import encode_ascii, decode_ascii, fileobj_closed, fileobj_is_binary
from ._utils import parse_header

from astropy.utils import isiterable
from astropy.utils.exceptions import AstropyUserWarning
from astropy.utils.decorators import deprecated_renamed_argument


BLOCK_SIZE = 2880  # the FITS block size

# This regular expression can match a *valid* END card which just consists of
# the string 'END' followed by all spaces, or an *invalid* end card which
# consists of END, followed by any character that is *not* a valid character
# for a valid FITS keyword (that is, this is not a keyword like 'ENDER' which
# starts with 'END' but is not 'END'), followed by any arbitrary bytes.  An
# invalid end card may also consist of just 'END' with no trailing bytes.
HEADER_END_RE = re.compile(encode_ascii(
    r'(?:(?P<valid>END {77}) *)|(?P<invalid>END$|END {0,76}[^A-Z0-9_-])'))


# According to the FITS standard the only characters that may appear in a
# header record are the restricted ASCII chars from 0x20 through 0x7E.
VALID_HEADER_CHARS = set(map(chr, range(0x20, 0x7F)))
END_CARD = 'END' + ' ' * 77


__doctest_skip__ = ['Header', 'Header.*']


class Header:
====
4.0.dev24591
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '90,115p' astropy/io/fits/tests/test_header.py; sed -n '790,825p' astropy/io/fits/tests/test_header.py; sed -n '1760,1810p' astropy/io/fits/tests/test_header.py; grep -n \"class Test\" astropy/io/fits/tests/test_header.py | head -40"
}
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"decode_ascii\\|encode_ascii\" astropy/io/fits/card.py | head; grep -n \"def _fromcards\\|_BaseHDU.fromstring\\|fromstring(\" astropy/io/fits/hdu/base.py | head -20"
}
```

**tool result**

```

        c = fits.Card('abc', '<8 ch')
        assert str(c) == _pad("ABC     = '<8 ch   '")
        c = fits.Card('nullstr', '')
        assert str(c) == _pad("NULLSTR = ''")

    def test_boolean_value_card(self):
        """Test Card constructor with boolean value"""

        c = fits.Card("abc", True)
        assert str(c) == _pad("ABC     =                    T")

        c = fits.Card.fromstring('ABC     = F')
        assert c.value is False

    def test_long_integer_value_card(self):
        """Test Card constructor with long integer value"""

        c = fits.Card('long_int', -467374636747637647347374734737437)
        assert str(c) == _pad("LONG_INT= -467374636747637647347374734737437")

    def test_floating_point_value_card(self):
        """Test Card constructor with floating point value"""

        c = fits.Card('floatnum', -467374636747637647347374734737437.)

        header['FOO'] = ('BAR', 'BAZ')
        header['FOO2'] = (None, None)
        assert header['FOO'] == 'BAR'
        assert header['FOO2'] is None
        assert header[0] == 'BAR'
        assert header.comments[0] == 'BAZ'
        assert header.comments['FOO'] == 'BAZ'
        assert header.comments['FOO2'] == ''

    def test_header_set_value_to_none(self):
        """
        Setting the value of a card to None should simply give that card an
        undefined value.  Undefined value should map to None.
        """

        header = fits.Header()
        header['FOO'] = 'BAR'
        assert header['FOO'] == 'BAR'
        header['FOO'] = None
        assert header['FOO'] is None

        # Create a header that contains an undefined value and a defined
        # value.
        hstr = "UNDEF   = \nDEFINED = 42"
        header = fits.Header.fromstring(hstr, sep='\n')

        # Explicitly add a card with an UNDEFINED value
        c = fits.Card("UNDEF2", fits.card.UNDEFINED)
        header.extend([c])

        # And now assign an undefined value to the header through setitem
        header['UNDEF3'] = fits.card.UNDEFINED

        # Tuple assignment
        header.append(("UNDEF5", None, "Undefined value"), end=True)
        header.append("UNDEF6")
        # right place already
        header.set('C', before=123)
        assert list(header) == ['A', 'B', 'C']
        assert not header._modified

        header.set('C', after=123)
        assert list(header) == ['A', 'B', 'C']
        assert not header._modified

    def test_invalid_float_cards(self):
        """Regression test for https://aeon.stsci.edu/ssb/trac/pyfits/ticket/137"""

        # Create a header containing two of the problematic cards in the test
        # case where this came up:
        hstr = "FOCALLEN= +1.550000000000e+002\nAPERTURE= +0.000000000000e+000"
        h = fits.Header.fromstring(hstr, sep='\n')

        # First the case that *does* work prior to fixing this issue
        assert h['FOCALLEN'] == 155.0
        assert h['APERTURE'] == 0.0

        # Now if this were reserialized, would new values for these cards be
        # written with repaired exponent signs?
        with pytest.warns(fits.verify.VerifyWarning,
                          match='Verification reported errors'):
            assert (str(h.cards['FOCALLEN']) ==
                    _pad("FOCALLEN= +1.550000000000E+002"))
        assert h.cards['FOCALLEN']._modified
        with pytest.warns(fits.verify.VerifyWarning,
                          match='Verification reported errors'):
            assert (str(h.cards['APERTURE']) ==
                    _pad("APERTURE= +0.000000000000E+000"))
        assert h.cards['APERTURE']._modified
        assert h._modified

        # This is the case that was specifically causing problems; generating
        # the card strings *before* parsing the values.  Also, the card strings
        # really should be "fixed" before being returned to the user
        h = fits.Header.fromstring(hstr, sep='\n')
        with pytest.warns(fits.verify.VerifyWarning,
                          match='Verification reported errors'):
            assert (str(h.cards['FOCALLEN']) ==
                    _pad("FOCALLEN= +1.550000000000E+002"))
        assert h.cards['FOCALLEN']._modified
        with pytest.warns(fits.verify.VerifyWarning,
                          match='Verification reported errors'):
            assert (str(h.cards['APERTURE']) ==
                    _pad("APERTURE= +0.000000000000E+000"))
        assert h.cards['APERTURE']._modified

        assert h['FOCALLEN'] == 155.0
69:class TestHeaderFunctions(FitsTestCase):
2333:class TestRecordValuedKeywordCards(FitsTestCase):
```

**tool result**

```
248:    def fromstring(cls, data, checksum=False, ignore_missing_end=False,
406:                    'memory buffer.  fromstring() requires an object that '
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '230,280p' astropy/io/fits/hdu/base.py; sed -n '390,420p' astropy/io/fits/hdu/base.py; grep -rn \"\\.fromstring(\" astropy/io/fits | grep -v tests | head -30"
}
```

**assistant → tool `bash`**

```json
{
  "command": "grep -rn \"Header.fromstring\\|Card.fromstring\" docs | head -20; grep -n \"fromstring\" CHANGES.rst | head"
}
```

**tool result**

```
    @property
    def _has_data(self):
        return self._data_loaded and self.data is not None

    @classmethod
    def register_hdu(cls, hducls):
        cls._hdu_registry.add(hducls)

    @classmethod
    def unregister_hdu(cls, hducls):
        if hducls in cls._hdu_registry:
            cls._hdu_registry.remove(hducls)

    @classmethod
    def match_header(cls, header):
        raise NotImplementedError

    @classmethod
    def fromstring(cls, data, checksum=False, ignore_missing_end=False,
                   **kwargs):
        """
        Creates a new HDU object of the appropriate type from a string
        containing the HDU's entire header and, optionally, its data.

        Note: When creating a new HDU from a string without a backing file
        object, the data of that HDU may be read-only.  It depends on whether
        the underlying string was an immutable Python str/bytes object, or some
        kind of read-write memory buffer such as a `memoryview`.

        Parameters
        ----------
        data : str, bytearray, memoryview, ndarray
           A byte string containing the HDU's header and data.

        checksum : bool, optional
           Check the HDU's checksum and/or datasum.

        ignore_missing_end : bool, optional
           Ignore a missing end card in the header data.  Note that without the
           end card the end of the header may be ambiguous and resulted in a
           corrupt HDU.  In this case the assumption is that the first 2880
           block that does not begin with valid FITS header data is the
           beginning of the data.

        kwargs : optional
           May consist of additional keyword arguments specific to an HDU
           type--these correspond to keywords recognized by the constructors of
           different HDU classes such as `PrimaryHDU`, `ImageHDU`, or
           `BinTableHDU`.  Any unrecognized keyword arguments are simply
           ignored.
        """
                    # the classic Header parser, which has better support
                    # and reporting for the various issues that can be found
                    # in the wild.
                    data.seek(header_offset)
                    header = Header.fromfile(data,
                                             endcard=not ignore_missing_end)
            hdu_fileobj = data
            data_offset = data.tell()  # *after* reading the header
        else:
            try:
                # Test that the given object supports the buffer interface by
                # ensuring an ndarray can be created from it
                np.ndarray((), dtype='ubyte', buffer=data)
            except TypeError:
                raise TypeError(
                    'The provided object {!r} does not contain an underlying '
                    'memory buffer.  fromstring() requires an object that '
                    'supports the buffer interface such as bytes, buffer, '
                    'memoryview, ndarray, etc.  This restriction is to ensure '
                    'that efficient access to the array/table data is possible.'
                    .format(data))

            if header is None:
                def block_iter(nbytes):
                    idx = 0
                    while idx < len(data):
                        yield data[idx:idx + nbytes]
                        idx += nbytes

                header_str, header = Header._from_blocks(
                    block_iter, True, '', not ignore_missing_end, True)
astropy/io/fits/diff.py:773:            a = Header.fromstring(a)
astropy/io/fits/diff.py:775:            b = Header.fromstring(b)
astropy/io/fits/header.py:380:                cards.append(Card.fromstring(''.join(image)))
astropy/io/fits/header.py:395:            cards.append(Card.fromstring(''.join(image)))
astropy/io/fits/header.py:542:        return header_str, cls.fromstring(header_str, sep=sep)
astropy/io/fits/header.py:1917:                hdr = Header.fromstring(obj._header_str)
astropy/io/fits/header.py:1956:            card = Card.fromstring(cardstr)
astropy/io/fits/header.py:1995:            self._cards[key] = card = Card.fromstring(cardstr)
astropy/io/fits/hdu/hdulist.py:1159:                    hdu = _BaseHDU.fromstring(data, **kwargs)
astropy/io/fits/card.py:1168:            card = Card.fromstring(self._image[idx:idx + Card.length])
```

**tool result**

```
docs/io/fits/usage/headers.rst:278:to the FITS standard (e.g. for testing purposes), the :meth:`Card.fromstring`
docs/io/fits/usage/headers.rst:287:    >>> c1 = fits.Card.fromstring('ABC = 3.456D023')
docs/io/fits/usage/headers.rst:288:    >>> c2 = fits.Card.fromstring("P.I. ='Hubble'")
docs/io/fits/usage/verification.rst:196:    >>> c = fits.Card.fromstring('FIX1    = 2.1e23')
docs/io/fits/usage/verification.rst:203:    >>> c = fits.Card.fromstring('FIX2= 2')
docs/io/fits/usage/verification.rst:210:    >>> c = fits.Card.fromstring('FIX3    = string value without quotes')
docs/io/fits/usage/verification.rst:219:    >>> c = fits.Card.fromstring('FIX5    = 2.4 e 03')
docs/io/fits/usage/verification.rst:226:    >>> c = fits.Card.fromstring('FIX6    = 2 10 ')
docs/io/fits/usage/verification.rst:247:    >>> c = fits.Card.fromstring("P.I. = 'Hubble'")
docs/io/fits/appendix/history.rst:72:  - The ``create_card_from_string`` factory function.  Use ``Card.fromstring``
docs/io/fits/appendix/history.rst:1437:  * The ``Card.fromstring()`` method is now a classmethod.  It returns a new
docs/io/fits/appendix/faq.rst:376:    >>> c = fits.Card.fromstring('FOO     = 1234567890.123456789')
8299:- The ``.fromstring`` classmethod of each HDU type has been simplified such
8324:- The ``create_card_from_string`` factory function.  Use ``Card.fromstring``
```

**assistant → tool `bash`**

```json
{
  "command": "git log --oneline --all -- astropy/io/fits/header.py | head -10; git log -S \"isinstance(data, bytes)\" --oneline --all -- astropy/io/fits/header.py | head"
}
```

**assistant → tool `bash`**

```json
{
  "command": "git log --oneline -3; git branch --show-current; ls .memdoor 2>/dev/null | head"
}
```

**tool result**

```
667cbfb2b Add comments about the implementation
67995dbe8 Use str instead of bytes for the header parsing
a0fc5f5e3 Use cython for the header parser
183faa9b9 Add comments and remove prints
7740207bd Check padding bytes also in _BasicHeader
225a844c6 Fix failure with TestCompressionFunction.test_missing_internal_header
637d92e72 Use a descriptor to load the header when ._header is accessed
43e7a96c3 Add missing attributes
1b4af32d2 Make the class private and add comments and docstrings
e74726b49 Add a fast Header parsing for the HDUs creation
```

**tool result**

```
7b678175a SWE-bench
a85a0747c Merge pull request #8693 from taldcroft/whatsnew-aldcroft
cb27bed8f Add entries to the release highlights list and refs
main
runs
runs.db
runs.db-shm
runs.db-wal
workflows
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"fromfile\\|fromstring\\|def test_.*string\" astropy/io/fits/tests/test_header.py | head -50; sed -n '69,110p' astropy/io/fits/tests/test_header.py"
}
```

**tool result**

```
88:    def test_string_value_card(self):
102:        c = fits.Card.fromstring('ABC     = F')
253:    def test_commentary_card_created_by_fromstring(self):
254:        # commentary card created by fromstring()
255:        c = fits.Card.fromstring(
264:        c = fits.Card.fromstring("HISTORY  (1, 2)")
270:        c = fits.Card.fromstring("HISTORY =   (1, 2)")
276:        c = fits.Card.fromstring(str(c))
285:    def test_complex_number_using_string_input(self):
287:        c = fits.Card.fromstring('ABC     = (8, 9)')
292:        c = fits.Card.fromstring('abc     = +  2.1   e + 12')
302:        c = fits.Card.fromstring(
310:    def test_undefined_value_using_string_input(self):
312:        c = fits.Card.fromstring('ABC     =    ')
317:        c = fits.Card.fromstring('XYZ= 100')
331:        c = fits.Card.fromstring("HISTO       =   (1, 2)")
338:        c = fits.Card.fromstring("   HISTORY          (1, 2)")
345:        c = fits.Card.fromstring('ABC= a6')
357:        c = fits.Card.fromstring('ABC= a6')
365:    def test_long_string_value(self):
376:    def test_long_unicode_string(self):
394:    def test_long_string_repr(self):
437:    def test_long_string_from_file(self):
454:    def test_word_in_long_string_too_long(self):
464:    def test_long_string_value_via_fromstring(self, capsys):
465:        # long string value via fromstring() method
466:        c = fits.Card.fromstring(
485:        c = fits.Card.fromstring(
543:        c = fits.Card.fromstring("HIERARCH key.META_4='calFileVersion'")
557:        c = fits.Card.fromstring(
814:        header = fits.Header.fromstring(hstr, sep='\n')
1663:            h = fits.Header.fromfile(s)
1674:            h = fits.Header.fromfile(s)
1683:            h = fits.Header.fromfile(s)
1696:            h = fits.Header.fromfile(s, padding=False)
1775:        h = fits.Header.fromstring(hstr, sep='\n')
1798:        h = fits.Header.fromstring(hstr, sep='\n')
1863:        c = fits.Card.fromstring("APERTURE= +0.000000000000E+000")
1866:        c = fits.Card.fromstring("APERTURE= 0.000000000000E+000")
1869:        c = fits.Card.fromstring("APERTURE= 017")
1899:        h.append(fits.Card.fromstring(fooimg))
1900:        h.append(fits.Card.fromstring(barimg))
2070:        c = fits.Card.fromstring("QUX     = 'Bar        '")
2128:        c1 = fits.Card.fromstring('CLFIND2D: contour = 0.30')
2129:        c2 = fits.Card.fromstring('Just some random text.')
2130:        c3 = fits.Card.fromstring('A' * 80)
2169:        c = fits.Card.fromstring('HIERARCH ESO DET CHIP PXSPACE = 5e6')
2325:            c = fits.Card.fromstring(card_image)
2361:        c = fits.Card.fromstring("DP1     = 'NAXIS: 2' / A comment")
2367:        c = fits.Card.fromstring("DP1     = 'NAXIS: 2.1'")
class TestHeaderFunctions(FitsTestCase):
    """Test Header and Card objects."""

    def test_rename_keyword(self):
        """Test renaming keyword with rename_keyword."""
        header = fits.Header([('A', 'B', 'C'), ('D', 'E', 'F')])
        header.rename_keyword('A', 'B')
        assert 'A' not in header
        assert 'B' in header
        assert header[0] == 'B'
        assert header['B'] == 'B'
        assert header.comments['B'] == 'C'

    def test_card_constructor_default_args(self):
        """Test Card constructor with default argument values."""

        c = fits.Card()
        assert '' == c.keyword

    def test_string_value_card(self):
        """Test Card constructor with string value"""

        c = fits.Card('abc', '<8 ch')
        assert str(c) == _pad("ABC     = '<8 ch   '")
        c = fits.Card('nullstr', '')
        assert str(c) == _pad("NULLSTR = ''")

    def test_boolean_value_card(self):
        """Test Card constructor with boolean value"""

        c = fits.Card("abc", True)
        assert str(c) == _pad("ABC     =                    T")

        c = fits.Card.fromstring('ABC     = F')
        assert c.value is False

    def test_long_integer_value_card(self):
        """Test Card constructor with long integer value"""

        c = fits.Card('long_int', -467374636747637647347374734737437)
        assert str(c) == _pad("LONG_INT= -467374636747637647347374734737437")
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: astropy/io/fits/card.py\n@@\n     @classmethod\n     def fromstring(cls, image):\n         \"\"\"\n         Construct a `Card` object from a (raw) string. It will pad the string\n         if it is not the length of a card image (80 columns).  If the card\n         image is longer than 80 columns, assume it contains ``CONTINUE``\n         card(s).\n         \"\"\"\n \n         card = cls()\n+        if isinstance(image, bytes):\n+            image = image.decode('ascii')\n         card._image = _pad(image)\n         card._verified = False\n         return card\n*** Update File: astropy/io/fits/header.py\n@@\n     def fromstring(cls, data, sep=''):\n         \"\"\"\n         Creates an HDU header from a byte string containing the entire header\n         data.\n \n         Parameters\n         ----------\n-        data : str\n-           String containing the entire header.\n+        data : str or bytes\n+           String or byte string containing the entire header.\n \n-        sep : str, optional\n+        sep : str or bytes, optional\n             The string separating cards from each other, such as a newline.  By\n             default there is no card separator (as is the case in a raw FITS\n             file).\n@@\n         header\n             A new `Header` instance.\n         \"\"\"\n \n+        if isinstance(data, bytes):\n+            data = decode_ascii(data)\n+\n+        if isinstance(sep, bytes):\n+            sep = decode_ascii(sep)\n+\n         cards = []\n*** Update File: astropy/io/fits/tests/test_header.py\n@@\n     def test_boolean_value_card(self):\n         \"\"\"Test Card constructor with boolean value\"\"\"\n@@\n         c = fits.Card.fromstring('ABC     = F')\n         assert c.value is False\n+\n+    def test_card_from_bytes(self):\n+        \"\"\"Regression test for https://github.com/astropy/astropy/issues/4970\n+\n+        `Card.fromstring` should accept both `str` and `bytes` input.\n+        \"\"\"\n+\n+        c = fits.Card.fromstring(b'ABC     = F')\n+        assert c.keyword == 'ABC'\n+        assert c.value is False\n+        assert str(c) == _pad('ABC     = F')\n+\n+    def test_header_from_bytes(self):\n+        \"\"\"Regression test for https://github.com/astropy/astropy/issues/4970\n+\n+        `Header.fromstring` should accept both `str` and `bytes` input.\n+        \"\"\"\n+\n+        hstr = b\"FOCALLEN= +1.550000000000e+002\\nAPERTURE= +0.000000000000e+000\"\n+        h = fits.Header.fromstring(hstr, sep=b'\\n')\n+        assert h['FOCALLEN'] == 155.0\n+        assert h['APERTURE'] == 0.0\n+\n+        h = fits.Header.fromstring(hstr, sep='\\n')\n+        assert h['FOCALLEN'] == 155.0\n+        assert h['APERTURE'] == 0.0\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[astropy/io/fits/card.py astropy/io/fits/header.py astropy/io/fits/tests/test_header.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

astropy/io/fits/card.py now (1287 lines), around the change:
554:        """
555:
556:        card = cls()
557:        if isinstance(image, bytes):
558:            image = image.decode('ascii')
559:        card._image = _pad(image)
560:        card._verified = False
561:        return card

astropy/io/fits/header.py now (2249 lines), around the change:
334:
335:        Parameters
336:        ----------
337:        data : str or bytes
338:           String or byte string containing the entire header.
339:
340:        sep : str or bytes, optional
341:            The string separating cards from each other, such as a newline.  By
342:            default there is no card separator (as is the case in a raw FITS
343:            file).
…
347:        header
348:            A new `Header` instance.
349:        """
350:
351:        if isinstance(data, bytes):
352:            data = decode_ascii(data)
353:
354:        if isinstance(sep, bytes):
355:            sep = decode_ascii(sep)
356:
357:        cards = []
358:

astropy/io/fits/tests/test_header.py now (2822 lines), around the change:
101:
102:        c = fits.Card.fromstring('ABC     = F')
103:        assert c.value is False
104:
105:    def test_card_from_bytes(self):
106:        """Regression test for https://github.com/astropy/astropy/issues/4970
107:
108:        `Card.fromstring` should accept both `str` and `bytes` input.
109:        """
110:
111:        c = fits.Card.fromstring(b'ABC     = F')
112:        assert c.keyword == 'ABC'
113:        assert c.value is False
114:        assert str(c) == _pad('ABC     = F')
115:
116:    def test_header_from_bytes(self):
117:        """Regression test for https://github.com/astropy/astropy/issues/4970
118:
119:        `Header.fromstring` should accept both `str` and `bytes` input.
120:        """
121:
122:        hstr = b"FOCALLEN= +1.550000000000e+002\nAPERTURE= +0.000000000000e+000"
123:        h = fits.Header.fromstring(hstr, sep=b'\n')
124:        assert h['FOCALLEN'] == 155.0
125:        assert h['APERTURE'] == 0.0
126:
127:        h = fits.Header.fromstring(hstr, sep='\n')
128:        assert h['FOCALLEN'] == 155.0
129:        assert h['APERTURE'] == 0.0
130:
131:    def test_long_integer_value_card(self):
132:        """Test Card constructor with long integer value"""
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest astropy/io/fits/tests/test_header.py -q -k \"bytes or fromstring or leading_zeros\" 2>&1 | tail -30"
}
```

**tool result**

```
Internet access disabled
.....                                                                    [100%]
5 passed, 147 deselected in 0.77s
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest astropy/io/fits/tests/test_header.py astropy/io/fits/tests/test_hdulist.py -q 2>&1 | tail -20"
}
```

**tool result**

```
E           The aliases was originally deprecated in NumPy 1.20; for more details and guidance see the original release note at:
E               https://numpy.org/devdocs/release/1.20.0-notes.html#deprecations

/opt/miniconda3/envs/testbed/lib/python3.9/site-packages/numpy/__init__.py:319: AttributeError
=========================== short test summary info ============================
FAILED astropy/io/fits/tests/test_header.py::TestRecordValuedKeywordCards::test_fitsheader_script
FAILED astropy/io/fits/tests/test_header.py::TestRecordValuedKeywordCards::test_fitsheader_table_feature
FAILED astropy/io/fits/tests/test_hdulist.py::TestHDUListFunctions::test_hdu_file_bytes
FAILED astropy/io/fits/tests/test_hdulist.py::TestHDUListFunctions::test_hdulist_file_info
FAILED astropy/io/fits/tests/test_hdulist.py::TestHDUListFunctions::test_append_table_extension_to_empty_list
FAILED astropy/io/fits/tests/test_hdulist.py::TestHDUListFunctions::test_append_extension_to_non_empty_list
FAILED astropy/io/fits/tests/test_hdulist.py::TestHDUListFunctions::test_insert_table_extension_to_empty_list
FAILED astropy/io/fits/tests/test_hdulist.py::TestHDUListFunctions::test_insert_extension_to_non_empty_list
FAILED astropy/io/fits/tests/test_hdulist.py::TestHDUListFunctions::test_insert_extension_to_primary_in_non_empty_list
FAILED astropy/io/fits/tests/test_hdulist.py::TestHDUListFunctions::test_insert_image_extension_to_primary_in_non_empty_list
FAILED astropy/io/fits/tests/test_hdulist.py::TestHDUListFunctions::test_update_with_truncated_header
FAILED astropy/io/fits/tests/test_hdulist.py::TestHDUListFunctions::test_hdul_fromstring
FAILED astropy/io/fits/tests/test_hdulist.py::TestHDUListFunctions::test_replace_mmap_data_2
FAILED astropy/io/fits/tests/test_hdulist.py::TestHDUListFunctions::test_pop_with_lazy_load
14 failed, 191 passed in 4.20s
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest astropy/io/fits/tests/test_hdulist.py::TestHDUListFunctions::test_hdul_fromstring -q 2>&1 | head -60"
}
```

**tool result**

```
Internet access disabled
F                                                                        [100%]
=================================== FAILURES ===================================
__________________ TestHDUListFunctions.test_hdul_fromstring ___________________

self = [<astropy.io.fits.hdu.image.PrimaryHDU object at 0x75819067fe20>]
func = <built-in method __getitem__ of HDUList object at 0x758190694770>
args = (1,), kwargs = {}

    def _try_while_unread_hdus(self, func, *args, **kwargs):
        """
        Attempt an operation that accesses an HDU by index/name
        that can fail if not all HDUs have been read yet.  Keep
        reading HDUs until the operation succeeds or there are no
        more HDUs to read.
        """
    
        while True:
            try:
>               return func(*args, **kwargs)
E               IndexError: list index out of range

astropy/io/fits/hdu/hdulist.py:1096: IndexError

During handling of the above exception, another exception occurred:

self = <astropy.io.fits.tests.test_hdulist.TestHDUListFunctions object at 0x7581a072b250>

    @ignore_warnings()
    def test_hdul_fromstring(self):
        """
        Test creating the HDUList structure in memory from a string containing
        an entire FITS file.  This is similar to test_hdu_fromstring but for an
        entire multi-extension FITS file at once.
        """
    
        # Tests HDUList.fromstring for all of Astropy's built in test files
        def test_fromstring(filename):
            with fits.open(filename) as hdul:
                orig_info = hdul.info(output=False)
                with open(filename, 'rb') as f:
                    dat = f.read()
    
                hdul2 = fits.HDUList.fromstring(dat)
    
                assert orig_info == hdul2.info(output=False)
                for idx in range(len(hdul)):
                    assert hdul[idx].header == hdul2[idx].header
                    if hdul[idx].data is None or hdul2[idx].data is None:
                        assert hdul[idx].data == hdul2[idx].data
                    elif (hdul[idx].data.dtype.fields and
                          hdul2[idx].data.dtype.fields):
                        # Compare tables
                        for n in hdul[idx].data.names:
                            c1 = hdul[idx].data[n]
                            c2 = hdul2[idx].data[n]
                            assert (c1 == c2).all()
                    elif (any(dim == 0 for dim in hdul[idx].data.shape) or
                          any(dim == 0 for dim in hdul2[idx].data.shape)):
                        # For some reason some combinations of Python and Numpy
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest astropy/io/fits/tests/test_hdulist.py::TestHDUListFunctions::test_hdul_fromstring -q 2>&1 | sed -n '60,160p'"
}
```

**tool result**

```
                        # For some reason some combinations of Python and Numpy
                        # on Windows result in MemoryErrors when trying to work
                        # on memmap arrays with more than one dimension but
                        # some dimensions of size zero, so include a special
                        # case for that
                        return hdul[idx].data.shape == hdul2[idx].data.shape
                    else:
                        np.testing.assert_array_equal(hdul[idx].data,
                                                      hdul2[idx].data)
    
        for filename in glob.glob(os.path.join(self.data_dir, '*.fits')):
            if sys.platform == 'win32' and filename == 'zerowidth.fits':
                # Running this test on this file causes a crash in some
                # versions of Numpy on Windows.  See ticket:
                # https://aeon.stsci.edu/ssb/trac/pyfits/ticket/174
                continue
            elif filename.endswith('variable_length_table.fits'):
                # Comparing variable length arrays is non-trivial and thus
                # skipped at this point.
                # TODO: That's probably possible, so one could make it work.
                continue
>           test_fromstring(filename)

astropy/io/fits/tests/test_hdulist.py:743: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
astropy/io/fits/tests/test_hdulist.py:702: in test_fromstring
    orig_info = hdul.info(output=False)
astropy/io/fits/hdu/hdulist.py:993: in info
    for idx, hdu in enumerate(self):
astropy/io/fits/hdu/hdulist.py:247: in __iter__
    yield self[idx]
astropy/io/fits/hdu/hdulist.py:299: in __getitem__
    return self._try_while_unread_hdus(super().__getitem__,
astropy/io/fits/hdu/hdulist.py:1098: in _try_while_unread_hdus
    if self._read_next_hdu():
astropy/io/fits/hdu/hdulist.py:1139: in _read_next_hdu
    hdu = _BaseHDU.readfrom(fileobj, **kwargs)
astropy/io/fits/hdu/base.py:315: in readfrom
    hdu = cls._readfrom_internal(fileobj, checksum=checksum,
astropy/io/fits/hdu/base.py:444: in _readfrom_internal
    hdu = cls(data=DELAYED, header=header, **new_kwargs)
astropy/io/fits/hdu/table.py:843: in __init__
    from astropy.table import Table
astropy/table/__init__.py:41: in <module>
    from .column import Column, MaskedColumn, StringTruncateWarning, ColumnInfo
astropy/table/column.py:28: in <module>
    from .np_utils import fix_column_name
astropy/table/np_utils.py:16: in <module>
    from . import _np_utils
astropy/table/_np_utils.pyx:15: in init astropy.table._np_utils
    DTYPE = np.int
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

attr = 'int'

    def __getattr__(attr):
        # Warn for expired attributes, and return a dummy function
        # that always raises an exception.
        import warnings
        import math
        try:
            msg = __expired_functions__[attr]
        except KeyError:
            pass
        else:
            warnings.warn(msg, DeprecationWarning, stacklevel=2)
    
            def _expired(*args, **kwds):
                raise RuntimeError(msg)
    
            return _expired
    
        # Emit warnings for deprecated attributes
        try:
            val, msg = __deprecated_attrs__[attr]
        except KeyError:
            pass
        else:
            warnings.warn(msg, DeprecationWarning, stacklevel=2)
            return val
    
        if attr in __future_scalars__:
            # And future warnings for those that will change, but also give
            # the AttributeError
            warnings.warn(
                f"In the future `np.{attr}` will be defined as the "
                "corresponding NumPy scalar.", FutureWarning, stacklevel=2)
    
        if attr in __former_attrs__:
>           raise AttributeError(__former_attrs__[attr])
E           AttributeError: module 'numpy' has no attribute 'int'.
E           `np.int` was a deprecated alias for the builtin `int`. To avoid this error in existing code, use `int` by itself. Doing this will not modify any behavior and is safe. When replacing `np.int`, you may wish to use e.g. `np.int64` or `np.int32` to specify the precision. If you wish to review your current use, check the release note link for additional information.
E           The aliases was originally deprecated in NumPy 1.20; for more details and guidance see the original release note at:
E               https://numpy.org/devdocs/release/1.20.0-notes.html#deprecations

/opt/miniconda3/envs/testbed/lib/python3.9/site-packages/numpy/__init__.py:319: AttributeError
=========================== short test summary info ============================
FAILED astropy/io/fits/tests/test_hdulist.py::TestHDUListFunctions::test_hdul_fromstring
1 failed in 0.59s
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"from .util import\" astropy/io/fits/card.py"
}
```

**tool result**

```
8:from .util import _str_to_num, _is_int, translate, _words_group
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest astropy/io/fits/tests/test_header.py -q 2>&1 | tail -8; python -m pytest astropy/io/fits/tests/test_header.py::TestRecordValuedKeywordCards::test_fitsheader_script -q 2>&1 | grep -E \"Error|assert\" | tail -5"
}
```

**tool result**

```
E           The aliases was originally deprecated in NumPy 1.20; for more details and guidance see the original release note at:
E               https://numpy.org/devdocs/release/1.20.0-notes.html#deprecations

/opt/miniconda3/envs/testbed/lib/python3.9/site-packages/numpy/__init__.py:319: AttributeError
=========================== short test summary info ============================
FAILED astropy/io/fits/tests/test_header.py::TestRecordValuedKeywordCards::test_fitsheader_script
FAILED astropy/io/fits/tests/test_header.py::TestRecordValuedKeywordCards::test_fitsheader_table_feature
2 failed, 150 passed in 1.62s
        except KeyError:
            # the AttributeError
>           raise AttributeError(__former_attrs__[attr])
E           AttributeError: module 'numpy' has no attribute 'int'.
/opt/miniconda3/envs/testbed/lib/python3.9/site-packages/numpy/__init__.py:319: AttributeError
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: astropy/io/fits/card.py\n@@\n-from .util import _str_to_num, _is_int, translate, _words_group\n+from .util import _str_to_num, _is_int, translate, _words_group, decode_ascii\n@@\n         card = cls()\n         if isinstance(image, bytes):\n-            image = image.decode('ascii')\n+            image = decode_ascii(image)\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[astropy/io/fits/card.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

astropy/io/fits/card.py now (1287 lines), around the change:
5:
6:import numpy as np
7:
8:from .util import _str_to_num, _is_int, translate, _words_group, decode_ascii
9:from .verify import _Verify, _ErrList, VerifyError, VerifyWarning
10:
11:from . import conf
…
555:
556:        card = cls()
557:        if isinstance(image, bytes):
558:            image = decode_ascii(image)
559:        card._image = _pad(image)
560:        card._verified = False
561:        return card
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: astropy/io/fits/card.py\n@@\n     def fromstring(cls, image):\n         \"\"\"\n-        Construct a `Card` object from a (raw) string. It will pad the string\n-        if it is not the length of a card image (80 columns).  If the card\n-        image is longer than 80 columns, assume it contains ``CONTINUE``\n-        card(s).\n+        Construct a `Card` object from a (raw) string or byte string.  It will\n+        pad the string if it is not the length of a card image (80 columns).\n+        If the card image is longer than 80 columns, assume it contains\n+        ``CONTINUE`` card(s).\n         \"\"\"\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[astropy/io/fits/card.py] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

astropy/io/fits/card.py now (1287 lines), around the change:
547:    @classmethod
548:    def fromstring(cls, image):
549:        """
550:        Construct a `Card` object from a (raw) string or byte string.  It will
551:        pad the string if it is not the length of a card image (80 columns).
552:        If the card image is longer than 80 columns, assume it contains
553:        ``CONTINUE`` card(s).
554:        """
555:
556:        card = cls()
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '1,80p' CHANGES.rst"
}
```

**tool result**

```
4.0 (unreleased)
================

New Features
------------

astropy.config
^^^^^^^^^^^^^^

astropy.constants
^^^^^^^^^^^^^^^^^

astropy.convolution
^^^^^^^^^^^^^^^^^^^

astropy.coordinates
^^^^^^^^^^^^^^^^^^^

astropy.cosmology
^^^^^^^^^^^^^^^^^

astropy.extern
^^^^^^^^^^^^^^

astropy.io.ascii
^^^^^^^^^^^^^^^^

astropy.io.misc
^^^^^^^^^^^^^^^

astropy.io.fits
^^^^^^^^^^^^^^^

astropy.io.registry
^^^^^^^^^^^^^^^^^^^

astropy.io.votable
^^^^^^^^^^^^^^^^^^

astropy.modeling
^^^^^^^^^^^^^^^^

astropy.nddata
^^^^^^^^^^^^^^

astropy.samp
^^^^^^^^^^^^

astropy.stats
^^^^^^^^^^^^^

astropy.table
^^^^^^^^^^^^^

astropy.tests
^^^^^^^^^^^^^

astropy.time
^^^^^^^^^^^^

astropy.timeseries
^^^^^^^^^^^^^^^^^^

astropy.uncertainty
^^^^^^^^^^^^^^^^^^^

astropy.units
^^^^^^^^^^^^^

astropy.utils
^^^^^^^^^^^^^

astropy.visualization
^^^^^^^^^^^^^^^^^^^^^

astropy.wcs
^^^^^^^^^^^

API Changes
-----------
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"astropy.io.fits\" CHANGES.rst | head -6; sed -n '80,130p' CHANGES.rst"
}
```

**tool result**

```
31:astropy.io.fits
106:astropy.io.fits
181:astropy.io.fits
267:astropy.io.fits
388:astropy.io.fits
578:astropy.io.fits
-----------

astropy.config
^^^^^^^^^^^^^^

astropy.constants
^^^^^^^^^^^^^^^^^

astropy.convolution
^^^^^^^^^^^^^^^^^^^

astropy.coordinates
^^^^^^^^^^^^^^^^^^^

astropy.cosmology
^^^^^^^^^^^^^^^^^

astropy.extern
^^^^^^^^^^^^^^

astropy.io.ascii
^^^^^^^^^^^^^^^^

astropy.io.misc
^^^^^^^^^^^^^^^

astropy.io.fits
^^^^^^^^^^^^^^^

astropy.io.registry
^^^^^^^^^^^^^^^^^^^

astropy.io.votable
^^^^^^^^^^^^^^^^^^

astropy.modeling
^^^^^^^^^^^^^^^^

astropy.nddata
^^^^^^^^^^^^^^

astropy.samp
^^^^^^^^^^^^

astropy.stats
^^^^^^^^^^^^^

astropy.table
^^^^^^^^^^^^^

astropy.tests
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '100,112p' CHANGES.rst"
}
```

**tool result**

```
astropy.io.ascii
^^^^^^^^^^^^^^^^

astropy.io.misc
^^^^^^^^^^^^^^^

astropy.io.fits
^^^^^^^^^^^^^^^

astropy.io.registry
^^^^^^^^^^^^^^^^^^^

astropy.io.votable
```

**assistant → tool `bash`**

```json
{
  "command": "grep -n \"^Bug Fixes\\|^Other Changes\\|^API Changes\\|^New Features\\|^Bug Fixes\" CHANGES.rst | head -10; sed -n '160,200p' CHANGES.rst"
}
```

**tool result**

```
4:New Features
79:API Changes
154:Bug Fixes
229:Other Changes and Additions
317:Other Changes and Additions
325:New Features
540:API Changes
672:Bug Fixes
811:Other Changes and Additions
910:New Features
astropy.constants
^^^^^^^^^^^^^^^^^

astropy.convolution
^^^^^^^^^^^^^^^^^^^

astropy.coordinates
^^^^^^^^^^^^^^^^^^^

astropy.cosmology
^^^^^^^^^^^^^^^^^

astropy.extern
^^^^^^^^^^^^^^

astropy.io.ascii
^^^^^^^^^^^^^^^^

astropy.io.misc
^^^^^^^^^^^^^^^

astropy.io.fits
^^^^^^^^^^^^^^^

astropy.io.registry
^^^^^^^^^^^^^^^^^^^

astropy.io.votable
^^^^^^^^^^^^^^^^^^

astropy.modeling
^^^^^^^^^^^^^^^^

astropy.nddata
^^^^^^^^^^^^^^

astropy.samp
^^^^^^^^^^^^

astropy.stats
^^^^^^^^^^^^^
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '154,190p' CHANGES.rst"
}
```

**tool result**

```
Bug Fixes
---------

astropy.config
^^^^^^^^^^^^^^

astropy.constants
^^^^^^^^^^^^^^^^^

astropy.convolution
^^^^^^^^^^^^^^^^^^^

astropy.coordinates
^^^^^^^^^^^^^^^^^^^

astropy.cosmology
^^^^^^^^^^^^^^^^^

astropy.extern
^^^^^^^^^^^^^^

astropy.io.ascii
^^^^^^^^^^^^^^^^

astropy.io.misc
^^^^^^^^^^^^^^^

astropy.io.fits
^^^^^^^^^^^^^^^

astropy.io.registry
^^^^^^^^^^^^^^^^^^^

astropy.io.votable
^^^^^^^^^^^^^^^^^^

astropy.modeling
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: CHANGES.rst\n@@\n astropy.io.fits\n ^^^^^^^^^^^^^^^\n \n+``Header.fromstring`` and ``Card.fromstring`` now accept both ``str`` and\n+``bytes`` input on Python 3. [#4970]\n+\n astropy.io.registry\n ^^^^^^^^^^^^^^^^^^^\n*** End Patch\n"
}
```

**tool result**

```
apply_patch update CHANGES.rst: the lines to change in /testbed/CHANGES.rst appear more than once (lines 31 and 106): add the unchanged line just above them as context, or an @@ line with the first line of the enclosing function. Nothing was written
```

**assistant → tool `bash`**

```json
{
  "command": "sed -n '25,36p' CHANGES.rst"
}
```

**tool result**

```
astropy.io.ascii
^^^^^^^^^^^^^^^^

astropy.io.misc
^^^^^^^^^^^^^^^

astropy.io.fits
^^^^^^^^^^^^^^^

astropy.io.registry
^^^^^^^^^^^^^^^^^^^
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: CHANGES.rst\n@@\n Bug Fixes\n ---------\n \n astropy.config\n ^^^^^^^^^^^^^^\n@@\n astropy.io.misc\n ^^^^^^^^^^^^^^^\n \n astropy.io.fits\n ^^^^^^^^^^^^^^^\n \n+``Header.fromstring`` and ``Card.fromstring`` now accept both ``str`` and\n+``bytes`` input on Python 3. [#4970]\n+\n astropy.io.registry\n ^^^^^^^^^^^^^^^^^^^\n*** End Patch\n"
}
```

**tool result**

```
apply_patch update CHANGES.rst: the lines to change in /testbed/CHANGES.rst appear more than once (lines 28 and 103): add the unchanged line just above them as context, or an @@ line with the first line of the enclosing function. Nothing was written
```

**assistant → tool `apply_patch`**

```json
{
  "input": "*** Begin Patch\n*** Update File: CHANGES.rst\n@@ Bug Fixes\n astropy.io.misc\n ^^^^^^^^^^^^^^^\n \n astropy.io.fits\n ^^^^^^^^^^^^^^^\n \n+``Header.fromstring`` and ``Card.fromstring`` now accept both ``str`` and\n+``bytes`` input on Python 3. [#4970]\n+\n astropy.io.registry\n ^^^^^^^^^^^^^^^^^^^\n*** End Patch\n"
}
```

**tool result**

```
Patch applied. added=[] modified=[CHANGES.rst] deleted=[]
Next: run the build/test with the bash tool and read the real output. If it fails (e.g. "undefined: X" means you called something you did not define yet), fix it with another patch. Do NOT report done until it builds and runs.

CHANGES.rst now (10885 lines), around the change:
180:
181:astropy.io.fits
182:^^^^^^^^^^^^^^^
183:
184:``Header.fromstring`` and ``Card.fromstring`` now accept both ``str`` and
185:``bytes`` input on Python 3. [#4970]
186:
187:astropy.io.registry
188:^^^^^^^^^^^^^^^^^^^
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest astropy/io/fits/tests/test_header.py -q 2>&1 | tail -6; python -m pytest astropy/io/fits/tests/test_hdulist.py -q 2>&1 | tail -4"
}
```

**tool result**

```

/opt/miniconda3/envs/testbed/lib/python3.9/site-packages/numpy/__init__.py:319: AttributeError
=========================== short test summary info ============================
FAILED astropy/io/fits/tests/test_header.py::TestRecordValuedKeywordCards::test_fitsheader_script
FAILED astropy/io/fits/tests/test_header.py::TestRecordValuedKeywordCards::test_fitsheader_table_feature
2 failed, 150 passed in 1.26s
FAILED astropy/io/fits/tests/test_hdulist.py::TestHDUListFunctions::test_hdul_fromstring
FAILED astropy/io/fits/tests/test_hdulist.py::TestHDUListFunctions::test_replace_mmap_data_2
FAILED astropy/io/fits/tests/test_hdulist.py::TestHDUListFunctions::test_pop_with_lazy_load
12 failed, 41 passed in 3.29s
```

**assistant → tool `bash`**

```json
{
  "command": "python -m pytest astropy/io/fits/tests/test_header.py -q -k \"bytes or fromstring\" 2>&1 | tail -4; git diff --stat; git diff -- astropy/io/fits"
}
```

**tool result**

```
Internet access disabled
....                                                                     [100%]
4 passed, 148 deselected in 0.09s
 CHANGES.rst                          |  3 +++
 astropy/io/fits/card.py              | 12 +++++++-----
 astropy/io/fits/header.py            | 12 +++++++++---
 astropy/io/fits/tests/test_header.py | 26 ++++++++++++++++++++++++++
 4 files changed, 45 insertions(+), 8 deletions(-)
diff --git a/astropy/io/fits/card.py b/astropy/io/fits/card.py
index 8c1ac5d73..d3fee8550 100644
--- a/astropy/io/fits/card.py
+++ b/astropy/io/fits/card.py
@@ -5,7 +5,7 @@ import warnings
 
 import numpy as np
 
-from .util import _str_to_num, _is_int, translate, _words_group
+from .util import _str_to_num, _is_int, translate, _words_group, decode_ascii
 from .verify import _Verify, _ErrList, VerifyError, VerifyWarning
 
 from . import conf
@@ -547,13 +547,15 @@ class Card(_Verify):
     @classmethod
     def fromstring(cls, image):
         """
-        Construct a `Card` object from a (raw) string. It will pad the string
-        if it is not the length of a card image (80 columns).  If the card
-        image is longer than 80 columns, assume it contains ``CONTINUE``
-        card(s).
+        Construct a `Card` object from a (raw) string or byte string.  It will
+        pad the string if it is not the length of a card image (80 columns).
+        If the card image is longer than 80 columns, assume it contains
+        ``CONTINUE`` card(s).
         """
 
         card = cls()
+        if isinstance(image, bytes):
+            image = decode_ascii(image)
         card._image = _pad(image)
         card._verified = False
         return card
diff --git a/astropy/io/fits/header.py b/astropy/io/fits/header.py
index ad07e6d52..6d059fbbf 100644
--- a/astropy/io/fits/header.py
+++ b/astropy/io/fits/header.py
@@ -334,10 +334,10 @@ class Header:
 
         Parameters
         ----------
-        data : str
-           String containing the entire header.
+        data : str or bytes
+           String or byte string containing the entire header.
 
-        sep : str, optional
+        sep : str or bytes, optional
             The string separating cards from each other, such as a newline.  By
             default there is no card separator (as is the case in a raw FITS
             file).
@@ -348,6 +348,12 @@ class Header:
             A new `Header` instance.
         """
 
+        if isinstance(data, bytes):
+            data = decode_ascii(data)
+
+        if isinstance(sep, bytes):
+            sep = decode_ascii(sep)
+
         cards = []
 
         # If the card separator contains characters that may validly appear in
diff --git a/astropy/io/fits/tests/test_header.py b/astropy/io/fits/tests/test_header.py
index 7c1725aed..7dccf70b5 100644
--- a/astropy/io/fits/tests/test_header.py
+++ b/astropy/io/fits/tests/test_header.py
@@ -102,6 +102,32 @@ class TestHeaderFunctions(FitsTestCase):
         c = fits.Card.fromstring('ABC     = F')
         assert c.value is False
 
+    def test_card_from_bytes(self):
+        """Regression test for https://github.com/astropy/astropy/issues/4970
+
+        `Card.fromstring` should accept both `str` and `bytes` input.
+        """
+
+        c = fits.Card.fromstring(b'ABC     = F')
+        assert c.keyword == 'ABC'
+        assert c.value is False
+        assert str(c) == _pad('ABC     = F')
+
+    def test_header_from_bytes(self):
+        """Regression test for https://github.com/astropy/astropy/issues/4970
+
+        `Header.fromstring` should accept both `str` and `bytes` input.
+        """
+
+        hstr = b"FOCALLEN= +1.550000000000e+002\nAPERTURE= +0.000000000000e+000"
+        h = fits.Header.fromstring(hstr, sep=b'\n')
+        assert h['FOCALLEN'] == 155.0
+        assert h['APERTURE'] == 0.0
+
+        h = fits.Header.fromstring(hstr, sep='\n')
+        assert h['FOCALLEN'] == 155.0
+        assert h['APERTURE'] == 0.0
+
     def test_long_integer_value_card(self):
         """Test Card constructor with long integer value"""
```

**assistant**

```
Implemented support for `bytes` in both `Header.fromstring` and `Card.fromstring`.

Changes:
- `astropy/io/fits/header.py`: `Header.fromstring` now decodes `bytes` `data` and `sep` via `decode_ascii` before parsing, and the docstring documents `str or bytes`.
- `astropy/io/fits/card.py`: `Card.fromstring` decodes `bytes` input via `decode_ascii`.
- Added regression tests for byte input to both methods in `astropy/io/fits/tests/test_header.py`.
- Added a changelog entry in `CHANGES.rst`.

Verification:
- Targeted tests pass: `4 passed` for byte/fromstring tests.
- Full header test file: `150 passed`, with only the two pre-existing `numpy` compatibility failures (`np.int` removed in NumPy 1.20) unrelated to this change.
```

## Run folder `team-solve-2026-11-06T104711`

Every file the workflow's steps wrote: the LLM steps' answers, the checks' logs, the patches, and the step that kept the final patch.

### `base.txt`

```
7b678175afc80be7e98db40c6e44360fc5b437fe
```

### `baseline-check.log`

```
check: python -m pytest astropy/io/fits/tests/test_header.py
WARNING: You appear to be trying to import astropy from within a source checkout without building the extension modules first.  Attempting to (re)build extension modules: [astropy]
Rebuilding extension modules [Done]
ERROR: An error occurred while attempting to rebuild the extension modules.  Please try manually running `./setup.py develop` or `./setup.py build_ext --inplace` to see what the issue was.  Extension modules must be successfully compiled and importable in order to import astropy. [astropy]
WARNING: You appear to be trying to import astropy from within a source checkout without building the extension modules first.  Attempting to (re)build extension modules: [astropy]
ERROR: An error occurred while attempting to rebuild the extension modules.  Please try manually running `./setup.py develop` or `./setup.py build_ext --inplace` to see what the issue was.  Extension modules must be successfully compiled and importable in order to import astropy. [astropy]
Traceback (most recent call last):
  File "/testbed/.memdoor/runs/team-solve-2026-11-06T104711/baseline-tree/astropy/__init__.py", line 185, in _initialize_astropy
    from .utils import _compiler
ImportError: cannot import name '_compiler' from 'astropy.utils' (/testbed/.memdoor/runs/team-solve-2026-11-06T104711/baseline-tree/astropy/utils/__init__.py)

During handling of the above exception, another exception occurred:

Traceback (most recent call last):
  File "/testbed/.memdoor/runs/team-solve-2026-11-06T104711/baseline-tree/astropy/__init__.py", line 194, in _initialize_astropy
    _rebuild_extensions()
  File "/testbed/.memdoor/runs/team-solve-2026-11-06T104711/baseline-tree/astropy/__init__.py", line 249, in _rebuild_extensions
    raise OSError('Running setup.py build_ext --inplace failed '
OSError: Running setup.py build_ext --inplace failed with error code 1: try rerunning this command manually to check what the error was.

During handling of the above exception, another exception occurred:

Traceback (most recent call last):
  File "/opt/miniconda3/envs/testbed/lib/python3.9/site-packages/_pytest/config/__init__.py", line 746, in import_plugin
    __import__(importspec)
  File "/testbed/.memdoor/runs/team-solve-2026-11-06T104711/baseline-tree/astropy/__init__.py", line 290, in <module>
    _initialize_astropy()
  File "/testbed/.memdoor/runs/team-solve-2026-11-06T104711/baseline-tree/astropy/__init__.py", line 196, in _initialize_astropy
    _rollback_import(
  File "/testbed/.memdoor/runs/team-solve-2026-11-06T104711/baseline-tree/astropy/__init__.py", line 182, in _rollback_import
    raise ImportError('astropy')
ImportError: astropy

The above exception was the direct cause of the following exception:

Traceback (most recent call last):
  File "/opt/miniconda3/envs/testbed/lib/python3.9/runpy.py", line 197, in _run_module_as_main
    return _run_code(code, main_globals, None,
  File "/opt/miniconda3/envs/testbed/lib/python3.9/runpy.py", line 87, in _run_code
    exec(code, run_globals)
  File "/opt/miniconda3/envs/testbed/lib/python3.9/site-packages/pytest/__main__.py", line 5, in <module>
    raise SystemExit(pytest.console_main())
  File "/opt/miniconda3/envs/testbed/lib/python3.9/site-packages/_pytest/config/__init__.py", line 187, in console_main
    code = main()
  File "/opt/miniconda3/envs/testbed/lib/python3.9/site-packages/_pytest/config/__init__.py", line 145, in main
    config = _prepareconfig(args, plugins)
  File "/opt/miniconda3/envs/testbed/lib/python3.9/site-packages/_pytest/config/__init__.py", line 324, in _prepareconfig
    config = pluginmanager.hook.pytest_cmdline_parse(
  File "/opt/miniconda3/envs/testbed/lib/python3.9/site-packages/pluggy/_hooks.py", line 493, in __call__
    return self._hookexec(self.name, self._hookimpls, kwargs, firstresult)
  File "/opt/miniconda3/envs/testbed/lib/python3.9/site-packages/pluggy/_manager.py", line 115, in _hookexec
    return self._inner_hookexec(hook_name, methods, kwargs, firstresult)
  File "/opt/miniconda3/envs/testbed/lib/python3.9/site-packages/pluggy/_callers.py", line 130, in _multicall
    teardown[0].send(outcome)
  File "/opt/miniconda3/envs/testbed/lib/python3.9/site-packages/_pytest/helpconfig.py", line 102, in pytest_cmdline_parse
    config: Config = outcome.get_result()
  File "/opt/miniconda3/envs/testbed/lib/python3.9/site-packages/pluggy/_result.py", line 114, in get_result
    raise exc.with_traceback(exc.__traceback__)
  File "/opt/miniconda3/envs/testbed/lib/python3.9/site-packages/pluggy/_callers.py", line 77, in _multicall
    res = hook_impl.function(*args)
  File "/opt/miniconda3/envs/testbed/lib/python3.9/site-packages/_pytest/config/__init__.py", line 1016, in pytest_cmdline_parse
    self.parse(args)
  File "/opt/miniconda3/envs/testbed/lib/python3.9/site-packages/_pytest/config/__init__.py", line 1304, in parse
    self._preparse(args, addopts=addopts)
  File "/opt/miniconda3/envs/testbed/lib/python3.9/site-packages/_pytest/config/__init__.py", line 1206, in _preparse
    self.hook.pytest_load_initial_conftests(
  File "/opt/miniconda3/envs/testbed/lib/python3.9/site-packages/pluggy/_hooks.py", line 493, in __call__
    return self._hookexec(self.name, self._hookimpls, kwargs, firstresult)
  File "/opt/miniconda3/envs/testbed/lib/python3.9/site-packages/pluggy/_manager.py", line 115, in _hookexec
    return self._inner_hookexec(hook_name, methods, kwargs, firstresult)
  File "/opt/miniconda3/envs/testbed/lib/python3.9/site-packages/pluggy/_callers.py", line 152, in _multicall
    return outcome.get_result()
  File "/opt/miniconda3/envs/testbed/lib/python3.9/site-packages/pluggy/_result.py", line 114, in get_result
    raise exc.with_traceback(exc.__traceback__)
  File "/opt/miniconda3/envs/testbed/lib/python3.9/site-packages/pluggy/_callers.py", line 77, in _multicall
    res = hook_impl.function(*args)
  File "/opt/miniconda3/envs/testbed/lib/python3.9/site-packages/_pytest/config/__init__.py", line 1083, in pytest_load_initial_conftests
    self.pluginmanager._set_initial_conftests(
  File "/opt/miniconda3/envs/testbed/lib/python3.9/site-packages/_pytest/config/__init__.py", line 529, in _set_initial_conftests
    self._try_load_conftest(anchor, namespace.importmode, rootpath)
  File "/opt/miniconda3/envs/testbed/lib/python3.9/site-packages/_pytest/config/__init__.py", line 546, in _try_load_conftest
    self._getconftestmodules(anchor, importmode, rootpath)
  File "/opt/miniconda3/envs/testbed/lib/python3.9/site-packages/_pytest/config/__init__.py", line 575, in _getconftestmodules
    mod = self._importconftest(conftestpath, importmode, rootpath)
  File "/opt/miniconda3/envs/testbed/lib/python3.9/site-packages/_pytest/config/__init__.py", line 623, in _importconftest
    self.consider_conftest(mod)
  File "/opt/miniconda3/envs/testbed/lib/python3.9/site-packages/_pytest/config/__init__.py", line 704, in consider_conftest
    self.register(conftestmodule, name=conftestmodule.__file__)
  File "/opt/miniconda3/envs/testbed/lib/python3.9/site-packages/_pytest/config/__init__.py", line 470, in register
    self.consider_module(plugin)
  File "/opt/miniconda3/envs/testbed/lib/python3.9/site-packages/_pytest/config/__init__.py", line 712, in consider_module
    self._import_plugin_specs(getattr(mod, "pytest_plugins", []))
  File "/opt/miniconda3/envs/testbed/lib/python3.9/site-packages/_pytest/config/__init__.py", line 719, in _import_plugin_specs
    self.import_plugin(import_spec)
  File "/opt/miniconda3/envs/testbed/lib/python3.9/site-packages/_pytest/config/__init__.py", line 748, in import_plugin
    raise ImportError(
  File "/opt/miniconda3/envs/testbed/lib/python3.9/site-packages/_pytest/config/__init__.py", line 746, in import_plugin
    __import__(importspec)
  File "/testbed/.memdoor/runs/team-solve-2026-11-06T104711/baseline-tree/astropy/__init__.py", line 290, in <module>
    _initialize_astropy()
  File "/testbed/.memdoor/runs/team-solve-2026-11-06T104711/baseline-tree/astropy/__init__.py", line 196, in _initialize_astropy
    _rollback_import(
  File "/testbed/.memdoor/runs/team-solve-2026-11-06T104711/baseline-tree/astropy/__init__.py", line 182, in _rollback_import
    raise ImportError('astropy')
ImportError: Error importing plugin "astropy.tests.plugins.display": astropy
Rebuilding extension modules [Done]
```

### `baseline-status.txt`

```
1
```

### `changes.diff`

```diff
diff --git a/CHANGES.rst b/CHANGES.rst
index 3dc79416e..2366449a4 100644
--- a/CHANGES.rst
+++ b/CHANGES.rst
@@ -181,6 +181,9 @@ astropy.io.misc
 astropy.io.fits
 ^^^^^^^^^^^^^^^
 
+``Header.fromstring`` and ``Card.fromstring`` now accept both ``str`` and
+``bytes`` input on Python 3. [#4970]
+
 astropy.io.registry
 ^^^^^^^^^^^^^^^^^^^
 
diff --git a/astropy/io/fits/card.py b/astropy/io/fits/card.py
index 8c1ac5d73..d3fee8550 100644
--- a/astropy/io/fits/card.py
+++ b/astropy/io/fits/card.py
@@ -5,7 +5,7 @@ import warnings
 
 import numpy as np
 
-from .util import _str_to_num, _is_int, translate, _words_group
+from .util import _str_to_num, _is_int, translate, _words_group, decode_ascii
 from .verify import _Verify, _ErrList, VerifyError, VerifyWarning
 
 from . import conf
@@ -547,13 +547,15 @@ class Card(_Verify):
     @classmethod
     def fromstring(cls, image):
         """
-        Construct a `Card` object from a (raw) string. It will pad the string
-        if it is not the length of a card image (80 columns).  If the card
-        image is longer than 80 columns, assume it contains ``CONTINUE``
-        card(s).
+        Construct a `Card` object from a (raw) string or byte string.  It will
+        pad the string if it is not the length of a card image (80 columns).
+        If the card image is longer than 80 columns, assume it contains
+        ``CONTINUE`` card(s).
         """
 
         card = cls()
+        if isinstance(image, bytes):
+            image = decode_ascii(image)
         card._image = _pad(image)
         card._verified = False
         return card
diff --git a/astropy/io/fits/header.py b/astropy/io/fits/header.py
index ad07e6d52..6d059fbbf 100644
--- a/astropy/io/fits/header.py
+++ b/astropy/io/fits/header.py
@@ -334,10 +334,10 @@ class Header:
 
         Parameters
         ----------
-        data : str
-           String containing the entire header.
+        data : str or bytes
+           String or byte string containing the entire header.
 
-        sep : str, optional
+        sep : str or bytes, optional
             The string separating cards from each other, such as a newline.  By
             default there is no card separator (as is the case in a raw FITS
             file).
@@ -348,6 +348,12 @@ class Header:
             A new `Header` instance.
         """
 
+        if isinstance(data, bytes):
+            data = decode_ascii(data)
+
+        if isinstance(sep, bytes):
+            sep = decode_ascii(sep)
+
         cards = []
 
         # If the card separator contains characters that may validly appear in
diff --git a/astropy/io/fits/tests/test_header.py b/astropy/io/fits/tests/test_header.py
index 7c1725aed..7dccf70b5 100644
--- a/astropy/io/fits/tests/test_header.py
+++ b/astropy/io/fits/tests/test_header.py
@@ -102,6 +102,32 @@ class TestHeaderFunctions(FitsTestCase):
         c = fits.Card.fromstring('ABC     = F')
         assert c.value is False
 
+    def test_card_from_bytes(self):
+        """Regression test for https://github.com/astropy/astropy/issues/4970
+
+        `Card.fromstring` should accept both `str` and `bytes` input.
+        """
+
+        c = fits.Card.fromstring(b'ABC     = F')
+        assert c.keyword == 'ABC'
+        assert c.value is False
+        assert str(c) == _pad('ABC     = F')
+
+    def test_header_from_bytes(self):
+        """Regression test for https://github.com/astropy/astropy/issues/4970
+
+        `Header.fromstring` should accept both `str` and `bytes` input.
+        """
+
+        hstr = b"FOCALLEN= +1.550000000000e+002\nAPERTURE= +0.000000000000e+000"
+        h = fits.Header.fromstring(hstr, sep=b'\n')
+        assert h['FOCALLEN'] == 155.0
+        assert h['APERTURE'] == 0.0
+
+        h = fits.Header.fromstring(hstr, sep='\n')
+        assert h['FOCALLEN'] == 155.0
+        assert h['APERTURE'] == 0.0
+
     def test_long_integer_value_card(self):
         """Test Card constructor with long integer value"""
```

### `check-kind.txt`

```
judge
```

### `context.md`

````
# task.md

# Task

## Prompt

Header.fromstring does not accept Python 3 bytes
According to [the docs](http://docs.astropy.org/en/stable/_modules/astropy/io/fits/header.html#Header.fromstring), the method `Header.fromstring` "...creates an HDU header from a byte string containing the entire header data."

By "byte string" here it really means the `str` type which on Python 2 could be raw binary data, but on Python 3 explicitly is not.   In fact it does work on Python 3's unicode `str`s, but here it assumes that the data can be ASCII-encoded.

Its counterpart, `Header.fromfile` will work with files opened in text or binary mode.  So probably the simplest solution for now (as opposed to adding new methods or something like that) is to change `Header.fromstring` to accept unicode or bytes string types.

`Card.fromstring` likely needs a similar treatment.

## Deliverable

changes to this tree

## Check

`python -m pytest astropy/io/fits/tests/test_header.py`

## Scope

`astropy/io/fits/header.py`
`astropy/io/fits/card.py`
`astropy/io/fits/tests/`

## Done when

`Header.fromstring` accepts a Python 3 `bytes` argument and produces the same header as the equivalent `str`.
`Header.fromstring` continues to accept unicode `str` input.
`Card.fromstring` accepts a Python 3 `bytes` argument and produces the same card as the equivalent `str`.
`Card.fromstring` continues to accept unicode `str` input.
Existing `Header` and `Card` string-input behavior is unchanged.



# plan.md

## Deliverable
changes to this tree

## Check
`python -m pytest astropy/io/fits/tests/test_header.py`

## Scope
`astropy/io/fits/header.py`
`astropy/io/fits/card.py`
`astropy/io/fits/tests/`

## Done when
`Header.fromstring` accepts a Python 3 `bytes` argument and produces the same header as the equivalent `str`.
`Header.fromstring` continues to accept unicode `str` input.
`Card.fromstring` accepts a Python 3 `bytes` argument and produces the same card as the equivalent `str`.
`Card.fromstring` continues to accept unicode `str` input.
Existing `Header` and `Card` string-input behavior is unchanged.

## Approach
Normalize `bytes` at the public entry points, then reuse the existing string parsing path. Decompose into: inspect `Header.fromstring` and `Card.fromstring`; decide where bytes-to-text conversion belongs; ensure `Header.fromstring` handles whole-header input before card splitting; ensure direct `Card.fromstring` calls handle bytes; run the focused fits header tests.

Candidate 1: decode bytes immediately inside `Header.fromstring` and `Card.fromstring` using the FITS-appropriate ASCII decoding, leaving all later parsing unchanged. Tradeoff: smallest, clearest change and preserves existing error paths for non-ASCII or malformed cards.

Candidate 2: add a shared private helper for “accept str or bytes, return str” and call it from both methods. Tradeoff: avoids duplicated decoding logic and can enforce consistent error messages, but touches more code and may affect other internal callers if adopted broadly.

Candidate 3: change `Header.fromstring` only and rely on it to pass decoded strings into `Card.fromstring`. Tradeoff: fixes the reported `Header` path but leaves direct `Card.fromstring` calls broken, so it does not satisfy the prompt’s likely `Card` requirement.

If the first attempt fails, check whether the failure is from decoding too late, after newline/card splitting, or from using an encoding that does not round-trip the FITS header bytes. Prefer decoding once at the method boundary and keeping the existing text-based logic intact.


# astropy/io/fits/header.py

```
# Licensed under a 3-clause BSD style license - see PYFITS.rst

import collections
import copy
import itertools
import re
import warnings

from .card import Card, _pad, KEYWORD_LENGTH, UNDEFINED
from .file import _File
from .util import encode_ascii, decode_ascii, fileobj_closed, fileobj_is_binary
from ._utils import parse_header

from astropy.utils import isiterable
from astropy.utils.exceptions import AstropyUserWarning
from astropy.utils.decorators import deprecated_renamed_argument


BLOCK_SIZE = 2880  # the FITS block size

# This regular expression can match a *valid* END card which just consists of
# the string 'END' followed by all spaces, or an *invalid* end card which
# consists of END, followed by any character that is *not* a valid character
# for a valid FITS keyword (that is, this is not a keyword like 'ENDER' which
# starts with 'END' but is not 'END'), followed by any arbitrary bytes.  An
# invalid end card may also consist of just 'END' with no trailing bytes.
HEADER_END_RE = re.compile(encode_ascii(
    r'(?:(?P<valid>END {77}) *)|(?P<invalid>END$|END {0,76}[^A-Z0-9_-])'))


# According to the FITS standard the only characters that may appear in a
# header record are the restricted ASCII chars from 0x20 through 0x7E.
VALID_HEADER_CHARS = set(map(chr, range(0x20, 0x7F)))
END_CARD = 'END' + ' ' * 77


__doctest_skip__ = ['Header', 'Header.*']


class Header:
    """
    FITS header class.  This class exposes both a dict-like interface and a
    list-like interface to FITS headers.

    The header may be indexed by keyword and, like a dict, the associated value
    will be returned.  When the header contains cards with duplicate keywords,
    only the value of the first card with the given keyword will be returned.
    It is also possible to use a 2-tuple as the index in the form (keyword,
    n)--this returns the n-th value with that keyword, in the case where there
    are duplicate keywords.

    For example::

        >>> header['NAXIS']
        0
        >>> header[('FOO', 1)]  # Return the value of the second FOO keyword
        'foo'

    The header may also be indexed by card number::

        >>> header[0]  # Return the value of the first card in the header
        'T'

    Commentary keywords such as HISTORY and COMMENT are special cases: When
    indexing the Header object with either 'HISTORY' or 'COMMENT' a list of all
    the HISTORY/COMMENT values is returned::

        >>> header['HISTORY']
        This is the first history entry in this header.
        This is the second history entry in this header.
        ...

    See the Astropy documentation for more details on working with headers.
    """

    def __init__(self, cards=[], copy=False):
        """
        Construct a `Header` from an iterable and/or text file.

        Parameters
        ----------
        cards : A list of `Card` objects, optional
            The cards to initialize the header with. Also allowed are other
            `Header` (or `dict`-like) objects.

            .. versionchanged:: 1.2
                Allowed ``cards`` to be a `dict`-like object.

        copy : bool, optional

            If ``True`` copies the ``cards`` if they were another `Header`
            instance.
            Default is ``False``.

            .. versionadded:: 1.3
        """
        self.clear()

        if isinstance(cards, Header):
            if copy:
                cards = cards.copy()
            cards = cards.cards
        elif isinstance(cards, dict):
            cards = cards.items()

        for card in cards:
            self.append(card, end=True)

        self._modified = False

    def __len__(self):
        return len(self._cards)

    def __iter__(self):
        for card in self._cards:
            yield card.keyword

    def __contains__(self, keyword):
        if keyword in self._keyword_indices or keyword in self._rvkc_indices:
            # For the most common case (single, standard form keyword lookup)
            # this will work and is an O(1) check.  If it fails that doesn't
            # guarantee absence, just that we have to perform the full set of
            # checks in self._cardindex
            return True
        try:
            self._cardindex(keyword)
        except (KeyError, IndexError):
            return False
        return True

    def __getitem__(self, key):
        if isinstance(key, slice):
            return Header([copy.copy(c) for c in self._cards[key]])
        elif self._haswildcard(key):
            return Header([copy.copy(self._cards[idx])
                           for idx in self._wildcardmatch(key)])
        elif (isinstance(key, str) and
              key.upper() in Card._commentary_keywords):
            key = key.upper()
            # Special case for commentary cards
            return _HeaderCommentaryCards(self, key)
        if isinstance(key, tuple):
            keyword = key[0]
        else:
            keyword = key
        card = self._cards[self._cardindex(key)]
        if card.field_specifier is not None and keyword == card.rawkeyword:
            # This is RVKC; if only the top-level keyword was specified return
            # the raw value, not the parsed out float value
            return card.rawvalue

        value = card.value
        if value == UNDEFINED:
            return None
        return value

    def __setitem__(self, key, value):
        if self._set_slice(key, value, self):
            return

        if isinstance(value, tuple):
            if not (0 < len(value) <= 2):
                raise ValueError(
                    'A Header item may be set with either a scalar value, '
                    'a 1-tuple containing a scalar value, or a 2-tuple '
                    'containing a scalar value and comment string.')
            if len(value) == 1:
                value, comment = value[0], None
                if value is None:
                    value = UNDEFINED
            elif len(value) == 2:
                value, comment = value
                if value is None:
                    value = UNDEFINED
                if comment is None:
                    comment = ''
        else:
            comment = None

        card = None
        if isinstance(key, int):
            card = self._cards[key]
        elif isinstance(key, tuple):
            card = self._cards[self._cardindex(key)]
        if value is None:
            value = UNDEFINED
        if card:
            card.value = value
            if comment is not None:
                card.comment = comment
            if card._modified:
                self._modified = True
        else:
            # If we get an IndexError that should be raised; we don't allow
            # assignment to non-existing indices
            self._update((key, value, comment))

    def __delitem__(self, key):
        if isinstance(key, slice) or self._haswildcard(key):
            # This is very inefficient but it's not a commonly used feature.
            # If someone out there complains that they make heavy use of slice
            # deletions and it's too slow, well, we can worry about it then
            # [the solution is not too complicated--it would be wait 'til all
            # the cards are deleted before updating _keyword_indices rather
            # than updating it once for each card that gets deleted]
            if isinstance(key, slice):
                indices = range(*key.indices(len(self)))
                # If the slice step is backwards we want to reverse it, because
                # it will be reversed in a few lines...
                if key.step and key.step < 0:
                    indices = reversed(indices)
            else:
                indices = self._wildcardmatch(key)
            for idx in reversed(indices):
                del self[idx]
            return
        elif isinstance(key, str):
            # delete ALL cards with the same keyword name
            key = Card.normalize_keyword(key)
            indices = self._keyword_indices
            if key not in self._keyword_indices:
                indices = self._rvkc_indices

            if key not in indices:
                # if keyword is not present raise KeyError.
                # To delete keyword without caring if they were present,
                # Header.remove(Keyword) can be used with optional argument ignore_missing as True
                raise KeyError("Keyword '{}' not found.".format(key))

            for idx in reversed(indices[key]):
                # Have to copy the indices list since it will be modified below
                del self[idx]
            return

        idx = self._cardindex(key)
        card = self._cards[idx]
        keyword = card.keyword
        del self._cards[idx]
        keyword = Card.normalize_keyword(keyword)
        indices = self._keyword_indices[keyword]
        indices.remove(idx)
        if not indices:
            del self._keyword_indices[keyword]

        # Also update RVKC indices if necessary :/
        if card.field_specifier is not None:
            indices = self._rvkc_indices[card.rawkeyword]
            indices.remove(idx)
            if not indices:
                del self._rvkc_indices[card.rawkeyword]

        # We also need to update all other indices
        self._updateindices(idx, increment=False)
        self._modified = True

    def __repr__(self):
        return self.tostring(sep='\n', endcard=False, padding=False)

    def __str__(self):
        return self.tostring()

    def __eq__(self, other):
        """
        Two Headers are equal only if they have the exact same string
        representation.
        """

        return str(self) == str(other)

    def __add__(self, other):
        temp = self.copy(strip=False)
        temp.extend(other)
        return temp

    def __iadd__(self, other):
        self.extend(other)
        return self

    def _ipython_key_completions_(self):
        return self.__iter__()

    @property
    def cards(self):
        """
        The underlying physical cards that make up this Header; it can be
        looked at, but it should not be modified directly.
        """

        return _CardAccessor(self)

    @property
    def comments(self):
        """
        View the comments associated with each keyword, if any.

        For example, to see the comment on the NAXIS keyword:

            >>> header.comments['NAXIS']
            number of data axes

        Comments can also be updated through this interface:

            >>> header.comments['NAXIS'] = 'Number of data axes'

        """

        return _HeaderComments(self)

    @property
    def _modified(self):
        """
        Whether or not the header has been modified; this is a property so that
        it can also check each card for modifications--cards may have been
        modified directly without the header containing it otherwise knowing.
        """

        modified_cards = any(c._modified for c in self._cards)
        if modified_cards:
            # If any cards were modified then by definition the header was
            # modified
            self.__dict__['_modified'] = True

        return self.__dict__['_modified']

    @_modified.setter
    def _modified(self, val):
        self.__dict__['_modified'] = val

    @classmethod
    def fromstring(cls, data, sep=''):
        """
        Creates an HDU header from a byte string containing the entire header
        data.

        Parameters
        ----------
        data : str
           String containing the entire header.

        sep : str, optional
            The string separating cards from each other, such as a newline.  By
            default there is no card separator (as is the case in a raw FITS
            file).

        Returns
        -------
        header
            A new `Header` instance.
        """

        cards = []

        # If the card separator contains characters that may validly appear in
        # a card, the only way to unambiguously distinguish between cards is to
        # require that they be Card.length long.  However, if the separator
        # contains non-valid characters (namely \n) the cards may be split
        # immediately at the separator
        require_full_cardlength = set(sep).issubset(VALID_HEADER_CHARS)

        # Split the header into individual cards
        idx = 0
        image = []

        while idx < len(data):
            if require_full_cardlength:
                end_idx = idx + Card.length
            else:
                try:
                    end_idx = data.index(sep, idx)
                except ValueError:
                    end_idx = len(data)

            next_image = data[idx:end_idx]
            idx = end_idx + len(sep)

            if image:
                if next_image[:8] == 'CONTINUE':
                    image.append(next_image)
                    continue
                cards.append(Card.fromstring(''.join(image)))

            if require_full_cardlength:
                if next_image == END_CARD:
                    image = []
                    break
            else:
                if next_image.split(sep)[0].rstrip() == 'END':
                    image = []
                    break

            image = [next_image]

        # Add the last image that was found before the end, if any
        if image:
            cards.append(Card.fromstring(''.join(image)))

        return cls._fromcards(cards)

    @classmethod
    def fromfile(cls, fileobj, sep='', endcard=True, padding=True):
        """
        Similar to :meth:`Header.fromstring`, but reads the header string from
        a given file-like object or filename.

        Parameters
        ----------
        fileobj : str, file-like
            A filename or an open file-like object from which a FITS header is
            to be read.  For open file handles the file pointer must be at the
            beginning of the header.

        sep : str, optional
            The string separating cards from each other, such as a newline.  By
            default there is no card separator (as is the case in a raw FITS
            file).

        endcard : bool, optional
            If True (the default) the header must end with an END card in order
            to be considered valid.  If an END card is not found an
            `OSError` is raised.

        padding : bool, optional
            If True (the default) the header will be required to be padded out
            to a multiple of 2880, the FITS header block size.  Otherwise any
            padding, or lack thereof, is ignored.

        Returns
        -------
        header
            A new `Header` instance.
        """

        close_file = False
        if isinstance(fileobj, str):
            # Open in text mode by default to support newline handling; if a
            # binary-mode file object is passed in, the user is on their own
            # with respect to newline handling
            fileobj = open(fileobj, 'r')
            close_file = True

        try:
            is_binary = fileobj_is_binary(fileobj)

            def block_iter(nbytes):
                while True:
                    data = fileobj.read(nbytes)

                    if data:
                        yield data
                    else:
                        break

            return cls._from_blocks(block_iter, is_binary, sep, endcard,
                                    padding)[1]
        finally:
            if close_file:
                fileobj.close()

    @classmethod
    def _fromcards(cls, cards):
        header = cls()
        for idx, card in enumerate(cards):
            header._cards.append(card)
            keyword = Card.normalize_keyword(card.keyword)
            header._keyword_indices[keyword].append(idx)
            if card.field_specifier is not None:
                header._rvkc_indices[card.rawkeyword].append(idx)

        header._modified = False
        return header

    @classmethod
    def _from_blocks(cls, block_iter, is_binary, sep, endcard, padding):
        """
        The meat of `Header.fromfile`; in a separate method so that
        `Header.fromfile` itself is just responsible for wrapping file
        handling.  Also used by `_BaseHDU.fromstring`.

        ``block_iter`` should be a callable which, given a block size n
        (typically 2880 bytes as used by the FITS standard) returns an iterator
        of byte strings of that block size.

        ``is_binary`` specifies whether the returned blocks are bytes or text

        Returns both the entire header *string*, and the `Header` object
        returned by Header.fromstring on that string.
        """

        actual_block_size = _block_size(sep)
        clen = Card.length + len(sep)

        blocks = block_iter(actual_block_size)

        # Read the first header block.
        try:
            block = next(blocks)
        except StopIteration:
            raise EOFError()

        if not is_binary:
            # TODO: There needs to be error handling at *this* level for
            # non-ASCII characters; maybe at this stage decoding latin-1 might
            # be safer
            block = encode_ascii(block)

        read_blocks = []
        is_eof = False
        end_found = False

        # continue reading header blocks until END card or EOF is reached
        while True:
            # find the END card
            end_found, block = cls._find_end_card(block, clen)

            read_blocks.append(decode_ascii(block))

            if end_found:
                break

            try:
                block = next(blocks)
            except StopIteration:
                is_eof = True
                break

            if not block:
                is_eof = True
                break

            if not is_binary:
                block = encode_ascii(block)

        if not end_found and is_eof and endcard:
            # TODO: Pass this error to validation framework as an ERROR,
            # rather than raising an exception
            raise OSError('Header missing END card.')

        header_str = ''.join(read_blocks)
        _check_padding(header_str, actual_block_size, is_eof,
                       check_block_size=padding)

        return header_str, cls.fromstring(header_str, sep=sep)

    @classmethod
    def _find_end_card(cls, block, card_len):
        """
        Utility method to search a header block for the END card and handle
        invalid END cards.

        This method can also returned a modified copy of the input header block
        in case an invalid end card needs to be sanitized.
        """

        for mo in HEADER_END_RE.finditer(block):
            # Ensure the END card was found, and it started on the
            # boundary of a new card (see ticket #142)
            if mo.start() % card_len != 0:
                continue

            # This must be the last header block, otherwise the
            # file is malformatted
            if mo.group('invalid'):
                offset = mo.start()
                trailing = block[offset + 3:offset + card_len - 3].rstrip()
                if trailing:
                    trailing = repr(trailing).lstrip('ub')
                    # TODO: Pass this warning up to the validation framework
                    warnings.warn(
                        'Unexpected bytes trailing END keyword: {0}; these '
                        'bytes will be replaced with spaces on write.'.format(
                            trailing), AstropyUserWarning)
                else:
                    # TODO: Pass this warning up to the validation framework
                    warnings.warn(
                        'Missing padding to end of the FITS block after the '
                        'END keyword; additional spaces will be appended to '
                        'the file upon writing to pad out to {0} '
                        'bytes.'.format(BLOCK_SIZE), AstropyUserWarning)

                # Sanitize out invalid END card now that the appropriate
                # warnings have been issued
                block = (block[:offset] + encode_ascii(END_CARD) +
                         block[offset + len(END_CARD):])

            return True, block

        return False, block

    def tostring(self, sep='', endcard=True, padding=True):
        r"""
        Returns a string representation of the header.

        By default this uses no separator between cards, adds the END card, and
        pads the string with spaces to the next multiple of 2880 bytes.  That
        is, it returns the header exactly as it would appear in a FITS file.

        Parameters
        ----------
        sep : str, optional
            The character or string with which to separate cards.  By default
            there is no separator, but one could use ``'\\n'``, for example, to
            separate each card with a new line

        endcard : bool, optional
            If True (default) adds the END card to the end of the header
            string

        padding : bool, optional
            If True (default) pads the string with spaces out to the next
            multiple of 2880 characters

        Returns
        -------
        s : str
            A string representing a FITS header.
        """

        lines = []
        for card in self._cards:
            s = str(card)
            # Cards with CONTINUE cards may be longer than 80 chars; so break
            # them into multiple lines
            while s:
                lines.append(s[:Card.length])
                s = s[Card.length:]

        s = sep.join(lines)
        if endcard:
            s += sep + _pad('END')
        if padding:
            s += ' ' * _pad_length(len(s))
        return s

    @deprecated_renamed_argument('clobber', 'overwrite', '2.0')
    def tofile(self, fileobj, sep='', endcard=True, padding=True,
               overwrite=False):
        r"""
        Writes the header to file or file-like object.

        By default this writes the header exactly as it would be written to a
        FITS file, with the END card included and padding to the next multiple
        of 2880 bytes.  However, aspects of this may be controlled.

        Parameters
        ----------
        fileobj : str, file, optional
            Either the pathname of a file, or an open file handle or file-like
            object

        sep : str, optional
            The character or string with which to separate cards.  By default
            there is no separator, but one could use ``'\\n'``, for example, to
            separate each card with a new line

        endcard : bool, optional
            If `True` (default) adds the END card to the end of the header
            string

        padding : bool, optional
            If `True` (default) pads the string with spaces out to the next
            multiple of 2880 characters

        overwrite : bool, optional
            If ``True``, overwrite the output file if it exists. Raises an
            ``OSError`` if ``False`` and the output file exists. Default is
            ``False``.

            .. versionchanged:: 1.3
               ``overwrite`` replaces the deprecated ``clobber`` argument.
        """

        close_file = fileobj_closed(fileobj)

        if not isinstance(fileobj, _File):
            fileobj = _File(fileobj, mode='ostream', overwrite=overwrite)

        try:
            blocks = self.tostring(sep=sep, endcard=endcard, padding=padding)
            actual_block_size = _block_size(sep)
            if padding and len(blocks) % actual_block_size != 0:
                raise OSError(
                    'Header size ({}) is not a multiple of block '
                    'size ({}).'.format(
                        len(blocks) - actual_block_size + BLOCK_SIZE,
                        BLOCK_SIZE))

            if not fileobj.simulateonly:
                fileobj.flush()
                try:
                    offset = fileobj.tell()
                except (AttributeError, OSError):
                    offset = 0
                fileobj.write(blocks.encode('ascii'))
                fileobj.flush()
        finally:
            if close_file:
                fileobj.close()

    @classmethod
    def fromtextfile(cls, fileobj, endcard=False):
        """
        Read a header from a simple text file or file-like object.

        Equivalent to::

            >>> Header.fromfile(fileobj, sep='\\n', endcard=False,
            ...                 padding=False)

        See Also
        --------
        fromfile
        """

        return cls.fromfile(fileobj, sep='\n', endcard=endcard, padding=False)

    @deprecated_renamed_argument('clobber', 'overwrite', '2.0')
    def totextfile(self, fileobj, endcard=False, overwrite=False):
        """
        Write the header as text to a file or a file-like object.

        Equivalent to::

            >>> Header.tofile(fileobj, sep='\\n', endcard=False,
            ...               padding=False, overwrite=overwrite)

        .. versionchanged:: 1.3
           ``overwrite`` replaces the deprecated ``clobber`` argument.

        See Also
        --------
        tofile
        """

        self.tofile(fileobj, sep='\n', endcard=endcard, padding=False,
                    overwrite=overwrite)

    def clear(self):
        """
        Remove all cards from the header.
        """

        self._cards = []
        self._keyword_indices = collections.defaultdict(list)
        self._rvkc_indices = collections.defaultdict(list)

    def copy(self, strip=False):
        """
        Make a copy of the :class:`Header`.

        .. versionchanged:: 1.3
            `copy.copy` and `copy.deepcopy` on a `Header` will call this
            method.

        Parameters
        ----------
        strip : bool, optional
           If `True`, strip any headers that are specific to one of the
           standard HDU types, so that this header can be used in a different
           HDU.

        Returns
        -------
        header
            A new :class:`Header` instance.
        """

        tmp = Header((copy.copy(card) for card in self._cards))
        if strip:
            tmp._strip()
        return tmp

    def __copy__(self):
        return self.copy()

    def __deepcopy__(self, *args, **kwargs):
        return self.copy()

    @classmethod
    def fromkeys(cls, iterable, value=None):
        """
        Similar to :meth:`dict.fromkeys`--creates a new `Header` from an
        iterable of keywords and an optional default value.

        This method is not likely to be particularly useful for creating real
        world FITS headers, but it is useful for testing.

        Parameters
        ----------
        iterable
            Any iterable that returns strings representing FITS keywords.

        value : optional
            A default value to assign to each keyword; must be a valid type for
            FITS keywords.

        Returns
        -------
        header
            A new `Header` instance.
        """

        d = cls()
        if not isinstance(value, tuple):
            value = (value,)
        for key in iterable:
            d.append((key,) + value)
        return d

    def get(self, key, default=None):
        """
        Similar to :meth:`dict.get`--returns the value associated with keyword
        in the header, or a default value if the keyword is not found.

        Parameters
        ----------
        key : str
            A keyword that may or may not be in the header.

        default : optional
            A default value to return if the keyword is not found in the
            header.

        Returns
        -------
        value
            The value associated with the given keyword, or the default value
            if the keyword is not in the header.
        """

        try:
            return self[key]
        except (KeyError, IndexError):
            return default

    def set(self, keyword, value=None, comment=None, before=None, after=None):
        """
        Set the value and/or comment and/or position of a specified keyword.

        If the keyword does not already exist in the header, a new keyword is
        created in the specified position, or appended to the end of the header
        if no position is specified.

        This method is similar to :meth:`Header.update` prior to Astropy v0.1.

        .. note::
            It should be noted that ``header.set(keyword, value)`` and
            ``header.set(keyword, value, comment)`` are equivalent to
            ``header[keyword] = value`` and
            ``header[keyword] = (value, comment)`` respectively.

            New keywords can also be inserted relative to existing keywords
            using, for example::

                >>> header.insert('NAXIS1', ('NAXIS', 2, 'Number of axes'))

            to insert before an existing keyword, or::

                >>> header.insert('NAXIS', ('NAXIS1', 4096), after=True)

            to insert after an existing keyword.

            The only advantage of using :meth:`Header.set` is that it
            easily replaces the old usage of :meth:`Header.update` both
            conceptually and in terms of function signature.

        Parameters
        ----------
        keyword : str
            A header keyword

        value : str, optional
            The value to set for the given keyword; if None the existing value
            is kept, but '' may be used to set a blank value

        comment : str, optional
            The comment to set for the given keyword; if None the existing
            comment is kept, but ``''`` may be used to set a blank comment

        before : str, int, optional
            Name of the keyword, or index of the `Card` before which this card
            should be located in the header.  The argument ``before`` takes
            precedence over ``after`` if both specified.

        after : str, int, optional
            Name of the keyword, or index of the `Card` after which this card
            should be located in the header.

        """

        # Create a temporary card that looks like the one being set; if the
        # temporary card turns out to be a RVKC this will make it easier to
        # deal with the idiosyncrasies thereof
        # Don't try to make a temporary card though if they keyword looks like
        # it might be a HIERARCH card or is otherwise invalid--this step is
        # only for validating RVKCs.
        if (len(keyword) <= KEYWORD_LENGTH and
            Card._keywd_FSC_RE.match(keyword) and
                keyword not in self._keyword_indices):
            new_card = Card(keyword, value, comment)
            new_keyword = new_card.keyword
        else:
            new_keyword = keyword

        if (new_keyword not in Card._commentary_keywords and
                new_keyword in self):
            if comment is None:
                comment = self.comments[keyword]
            if value is None:
                value = self[keyword]

            self[keyword] = (value, comment)

            if before is not None or after is not None:
                card = self._cards[self._cardindex(keyword)]
                self._relativeinsert(card, before=before, after=after,
                                     replace=True)
        elif before is not None or after is not None:
            self._relativeinsert((keyword, value, comment), before=before,
                                 after=after)
        else:
            self[keyword] = (value, comment)

    def items(self):
        """Like :meth:`dict.items`."""

        for card in self._cards:
            yield (card.keyword, card.value)

    def keys(self):
        """
        Like :meth:`dict.keys`--iterating directly over the `Header`
        instance has the same behavior.
        """

        for card in self._cards:
            yield card.keyword

    def values(self):
        """Like :meth:`dict.values`."""

        for card in self._cards:
            yield card.value

    def pop(self, *args):
        """
        Works like :meth:`list.pop` if no arguments or an index argument are
        supplied; otherwise works like :meth:`dict.pop`.
        """

        if len(args) > 2:
            raise TypeError('Header.pop expected at most 2 arguments, got '
                            '{}'.format(len(args)))

        if len(args) == 0:
            key = -1
        else:
            key = args[0]

        try:
            value = self[key]
        except (KeyError, IndexError):
            if len(args) == 2:
                return args[1]
            raise

        del self[key]
        return value

    def popitem(self):
        """Similar to :meth:`dict.popitem`."""

        try:
            k, v = next(self.items())
        except StopIteration:
            raise KeyError('Header is empty')
        del self[k]
        return k, v

    def setdefault(self, key, default=None):
        """Similar to :meth:`dict.setdefault`."""

        try:
            return self[key]
        except (KeyError, IndexError):
            self[key] = default
        return default

    def update(self, *args, **kwargs):
        """
        Update the Header with new keyword values, updating the values of
        existing keywords and appending new keywords otherwise; similar to
        `dict.update`.

        `update` accepts either a dict-like object or an iterable.  In the
        former case the keys must be header keywords and the values may be
        either scalar values or (value, comment) tuples.  In the case of an
        iterable the items must be (keyword, value) tuples or (keyword, value,
        comment) tuples.

        Arbitrary arguments are also accepted, in which case the update() is
        called again with the kwargs dict as its only argument.  That is,

        ::

            >>> header.update(NAXIS1=100, NAXIS2=100)

        is equivalent to::

            header.update({'NAXIS1': 100, 'NAXIS2': 100})

        .. warning::
            As this method works similarly to `dict.update` it is very
            different from the ``Header.update()`` method in Astropy v0.1.
            Use of the old API was
            **deprecated** for a long time and is now removed. Most uses of the
            old API can be replaced as follows:

            * Replace ::

                  header.update(keyword, value)

              with ::

                  header[keyword] = value

            * Replace ::

                  header.update(keyword, value, comment=comment)

              with ::

                  header[keyword] = (value, comment)

            * Replace ::

                  header.update(keyword, value, before=before_keyword)

              with ::

                  header.insert(before_keyword, (keyword, value))

            * Replace ::

                  header.update(keyword, value, after=after_keyword)

              with ::

                  header.insert(after_keyword, (keyword, value),
                                after=True)

            See also :meth:`Header.set` which is a new method that provides an
            interface similar to the old ``Header.update()`` and may help make
            transition a little easier.

        """

        if args:
            other = args[0]
        else:
            other = None

        def update_from_dict(k, v):
            if not isinstance(v, tuple):
                card = Card(k, v)
            elif 0 < len(v) <= 2:
                card = Card(*((k,) + v))
            else:
                raise ValueError(
                    'Header update value for key %r is invalid; the '
                    'value must be either a scalar, a 1-tuple '
                    'containing the scalar value, or a 2-tuple '
                    'containing the value and a comment string.' % k)
            self._update(card)

        if other is None:
            pass
        elif hasattr(other, 'items'):
            for k, v in other.items():
                update_from_dict(k, v)
        elif hasattr(other, 'keys'):
            for k in other.keys():
                update_from_dict(k, other[k])
        else:
            for idx, card in enumerate(other):
                if isinstance(card, Card):
                    self._update(card)
                elif isinstance(card, tuple) and (1 < len(card) <= 3):
                    self._update(Card(*card))
                else:
                    raise ValueError(
                        'Header update sequence item #{} is invalid; '
                        'the item must either be a 2-tuple containing '
                        'a keyword and value, or a 3-tuple containing '
                        'a keyword, value, and comment string.'.format(idx))
        if kwargs:
            self.update(kwargs)

    def append(self, card=None, useblanks=True, bottom=False, end=False):
        """
        Appends a new keyword+value card to the end of the Header, similar
        to `list.append`.

        By default if the last cards in the Header have commentary keywords,
        this will append the new keyword before the commentary (unless the new
        keyword is also commentary).

        Also differs from `list.append` in that it can be called with no
        arguments: In this case a blank card is appended to the end of the
        Header.  In the case all the keyword arguments are ignored.

        Parameters
        ----------
        card : str, tuple
            A keyword or a (keyword, value, [comment]) tuple representing a
            single header card; the comment is optional in which case a
            2-tuple may be used

        useblanks : bool, optional
            If there are blank cards at the end of the Header, replace the
            first blank card so that the total number of cards in the Header
            does not increase.  Otherwise preserve the number of blank cards.

        bottom : bool, optional
            If True, instead of appending after the last non-commentary card,
            append after the last non-blank card.

        end : bool, optional
            If True, ignore the useblanks and bottom options, and append at the
            very end of the Header.

        """

        if isinstance(card, str):
            card = Card(card)
        elif isinstance(card, tuple):
            card = Card(*card)
        elif card is None:
            card = Card()
        elif not isinstance(card, Card):
            raise ValueError(
                'The value appended to a Header must be either a keyword or '
                '(keyword, value, [comment]) tuple; got: {!r}'.format(card))

        if not end and card.is_blank:
            # Blank cards should always just be appended to the end
            end = True

        if end:
            self._cards.append(card)
            idx = len(self._cards) - 1
        else:
            idx = len(self._cards) - 1
            while idx >= 0 and self._cards[idx].is_blank:
                idx -= 1

            if not bottom and card.keyword not in Card._commentary_keywords:
                while (idx >= 0 and
                       self._cards[idx].keyword in Card._commentary_keywords):
                    idx -= 1

            idx += 1
            self._cards.insert(idx, card)
            self._updateindices(idx)

        keyword = Card.normalize_keyword(card.keyword)
        self._keyword_indices[keyword].append(idx)
        if card.field_specifier is not None:
            self._rvkc_indices[card.rawkeyword].append(idx)

        if not end:
            # If the appended card was a commentary card, and it was appended
            # before existing cards with the same keyword, the indices for
            # cards with that keyword may have changed
            if not bottom and card.keyword in Card._commentary_keywords:
                self._keyword_indices[keyword].sort()

            # Finally
```


# astropy/io/fits/card.py

```
# Licensed under a 3-clause BSD style license - see PYFITS.rst

import re
import warnings

import numpy as np

from .util import _str_to_num, _is_int, translate, _words_group
from .verify import _Verify, _ErrList, VerifyError, VerifyWarning

from . import conf
from astropy.utils.exceptions import AstropyUserWarning


__all__ = ['Card', 'Undefined']


FIX_FP_TABLE = str.maketrans('de', 'DE')
FIX_FP_TABLE2 = str.maketrans('dD', 'eE')


CARD_LENGTH = 80
BLANK_CARD = ' ' * CARD_LENGTH
KEYWORD_LENGTH = 8  # The max length for FITS-standard keywords

VALUE_INDICATOR = '= '  # The standard FITS value indicator
VALUE_INDICATOR_LEN = len(VALUE_INDICATOR)
HIERARCH_VALUE_INDICATOR = '='  # HIERARCH cards may use a shortened indicator


class Undefined:
    """Undefined value."""

    def __init__(self):
        # This __init__ is required to be here for Sphinx documentation
        pass


UNDEFINED = Undefined()


class Card(_Verify):

    length = CARD_LENGTH
    """The length of a Card image; should always be 80 for valid FITS files."""

    # String for a FITS standard compliant (FSC) keyword.
    _keywd_FSC_RE = re.compile(r'^[A-Z0-9_-]{0,%d}$' % KEYWORD_LENGTH)
    # This will match any printable ASCII character excluding '='
    _keywd_hierarch_RE = re.compile(r'^(?:HIERARCH +)?(?:^[ -<>-~]+ ?)+$',
                                    re.I)

    # A number sub-string, either an integer or a float in fixed or
    # scientific notation.  One for FSC and one for non-FSC (NFSC) format:
    # NFSC allows lower case of DE for exponent, allows space between sign,
    # digits, exponent sign, and exponents
    _digits_FSC = r'(\.\d+|\d+(\.\d*)?)([DE][+-]?\d+)?'
    _digits_NFSC = r'(\.\d+|\d+(\.\d*)?) *([deDE] *[+-]? *\d+)?'
    _numr_FSC = r'[+-]?' + _digits_FSC
    _numr_NFSC = r'[+-]? *' + _digits_NFSC

    # This regex helps delete leading zeros from numbers, otherwise
    # Python might evaluate them as octal values (this is not-greedy, however,
    # so it may not strip leading zeros from a float, which is fine)
    _number_FSC_RE = re.compile(r'(?P<sign>[+-])?0*?(?P<digt>{})'.format(
            _digits_FSC))
    _number_NFSC_RE = re.compile(r'(?P<sign>[+-])? *0*?(?P<digt>{})'.format(
            _digits_NFSC))

    # FSC commentary card string which must contain printable ASCII characters.
    # Note: \Z matches the end of the string without allowing newlines
    _ascii_text_re = re.compile(r'[ -~]*\Z')

    # Checks for a valid value/comment string.  It returns a match object
    # for a valid value/comment string.
    # The valu group will return a match if a FITS string, boolean,
    # number, or complex value is found, otherwise it will return
    # None, meaning the keyword is undefined.  The comment field will
    # return a match if the comment separator is found, though the
    # comment maybe an empty string.
    _value_FSC_RE = re.compile(
        r'(?P<valu_field> *'
            r'(?P<valu>'

                #  The <strg> regex is not correct for all cases, but
                #  it comes pretty darn close.  It appears to find the
                #  end of a string rather well, but will accept
                #  strings with an odd number of single quotes,
                #  instead of issuing an error.  The FITS standard
                #  appears vague on this issue and only states that a
                #  string should not end with two single quotes,
                #  whereas it should not end with an even number of
                #  quotes to be precise.
                #
                #  Note that a non-greedy match is done for a string,
                #  since a greedy match will find a single-quote after
                #  the comment separator resulting in an incorrect
                #  match.
                r'\'(?P<strg>([ -~]+?|\'\'|)) *?\'(?=$|/| )|'
                r'(?P<bool>[FT])|'
                r'(?P<numr>' + _numr_FSC + r')|'
                r'(?P<cplx>\( *'
                    r'(?P<real>' + _numr_FSC + r') *, *'
                    r'(?P<imag>' + _numr_FSC + r') *\))'
            r')? *)'
        r'(?P<comm_field>'
            r'(?P<sepr>/ *)'
            r'(?P<comm>[!-~][ -~]*)?'
        r')?$')

    _value_NFSC_RE = re.compile(
        r'(?P<valu_field> *'
            r'(?P<valu>'
                r'\'(?P<strg>([ -~]+?|\'\'|) *?)\'(?=$|/| )|'
                r'(?P<bool>[FT])|'
                r'(?P<numr>' + _numr_NFSC + r')|'
                r'(?P<cplx>\( *'
                    r'(?P<real>' + _numr_NFSC + r') *, *'
                    r'(?P<imag>' + _numr_NFSC + r') *\))'
            r')? *)'
        r'(?P<comm_field>'
            r'(?P<sepr>/ *)'
            r'(?P<comm>(.|\n)*)'
        r')?$')

    _rvkc_identifier = r'[a-zA-Z_]\w*'
    _rvkc_field = _rvkc_identifier + r'(\.\d+)?'
    _rvkc_field_specifier_s = r'{}(\.{})*'.format(_rvkc_field, _rvkc_field)
    _rvkc_field_specifier_val = (r'(?P<keyword>{}): (?P<val>{})'.format(
            _rvkc_field_specifier_s, _numr_FSC))
    _rvkc_keyword_val = r'\'(?P<rawval>{})\''.format(_rvkc_field_specifier_val)
    _rvkc_keyword_val_comm = (r' *{} *(/ *(?P<comm>[ -~]*))?$'.format(
            _rvkc_keyword_val))

    _rvkc_field_specifier_val_RE = re.compile(_rvkc_field_specifier_val + '$')

    # regular expression to extract the key and the field specifier from a
    # string that is being used to index into a card list that contains
    # record value keyword cards (ex. 'DP1.AXIS.1')
    _rvkc_keyword_name_RE = (
        re.compile(r'(?P<keyword>{})\.(?P<field_specifier>{})$'.format(
                _rvkc_identifier, _rvkc_field_specifier_s)))

    # regular expression to extract the field specifier and value and comment
    # from the string value of a record value keyword card
    # (ex "'AXIS.1: 1' / a comment")
    _rvkc_keyword_val_comm_RE = re.compile(_rvkc_keyword_val_comm)

    _commentary_keywords = {'', 'COMMENT', 'HISTORY', 'END'}
    _special_keywords = _commentary_keywords.union(['CONTINUE'])

    # The default value indicator; may be changed if required by a convention
    # (namely HIERARCH cards)
    _value_indicator = VALUE_INDICATOR

    def __init__(self, keyword=None, value=None, comment=None, **kwargs):
        # For backwards compatibility, support the 'key' keyword argument:
        if keyword is None and 'key' in kwargs:
            keyword = kwargs['key']

        self._keyword = None
        self._value = None
        self._comment = None
        self._valuestring = None
        self._image = None

        # This attribute is set to False when creating the card from a card
        # image to ensure that the contents of the image get verified at some
        # point
        self._verified = True

        # A flag to conveniently mark whether or not this was a valid HIERARCH
        # card
        self._hierarch = False

        # If the card could not be parsed according the the FITS standard or
        # any recognized non-standard conventions, this will be True
        self._invalid = False

        self._field_specifier = None

        # These are used primarily only by RVKCs
        self._rawkeyword = None
        self._rawvalue = None

        if not (keyword is not None and value is not None and
                self._check_if_rvkc(keyword, value)):
            # If _check_if_rvkc passes, it will handle setting the keyword and
            # value
            if keyword is not None:
                self.keyword = keyword
            if value is not None:
                self.value = value

        if comment is not None:
            self.comment = comment

        self._modified = False
        self._valuemodified = False

    def __repr__(self):
        return repr((self.keyword, self.value, self.comment))

    def __str__(self):
        return self.image

    def __len__(self):
        return 3

    def __getitem__(self, index):
        return (self.keyword, self.value, self.comment)[index]

    @property
    def keyword(self):
        """Returns the keyword name parsed from the card image."""
        if self._keyword is not None:
            return self._keyword
        elif self._image:
            self._keyword = self._parse_keyword()
            return self._keyword
        else:
            self.keyword = ''
            return ''

    @keyword.setter
    def keyword(self, keyword):
        """Set the key attribute; once set it cannot be modified."""
        if self._keyword is not None:
            raise AttributeError(
                'Once set, the Card keyword may not be modified')
        elif isinstance(keyword, str):
            # Be nice and remove trailing whitespace--some FITS code always
            # pads keywords out with spaces; leading whitespace, however,
            # should be strictly disallowed.
            keyword = keyword.rstrip()
            keyword_upper = keyword.upper()
            if (len(keyword) <= KEYWORD_LENGTH and
                self._keywd_FSC_RE.match(keyword_upper)):
                # For keywords with length > 8 they will be HIERARCH cards,
                # and can have arbitrary case keywords
                if keyword_upper == 'END':
                    raise ValueError("Keyword 'END' not allowed.")
                keyword = keyword_upper
            elif self._keywd_hierarch_RE.match(keyword):
                # In prior versions of PyFITS (*) HIERARCH cards would only be
                # created if the user-supplied keyword explicitly started with
                # 'HIERARCH '.  Now we will create them automatically for long
                # keywords, but we still want to support the old behavior too;
                # the old behavior makes it possible to create HEIRARCH cards
                # that would otherwise be recognized as RVKCs
                # (*) This has never affected Astropy, because it was changed
                # before PyFITS was merged into Astropy!
                self._hierarch = True
                self._value_indicator = HIERARCH_VALUE_INDICATOR

                if keyword_upper[:9] == 'HIERARCH ':
                    # The user explicitly asked for a HIERARCH card, so don't
                    # bug them about it...
                    keyword = keyword[9:].strip()
                else:
                    # We'll gladly create a HIERARCH card, but a warning is
                    # also displayed
                    warnings.warn(
                        'Keyword name {!r} is greater than 8 characters or '
                        'contains characters not allowed by the FITS '
                        'standard; a HIERARCH card will be created.'.format(
                            keyword), VerifyWarning)
            else:
                raise ValueError('Illegal keyword name: {!r}.'.format(keyword))
            self._keyword = keyword
            self._modified = True
        else:
            raise ValueError('Keyword name {!r} is not a string.'.format(keyword))

    @property
    def value(self):
        """The value associated with the keyword stored in this card."""

        if self.field_specifier:
            return float(self._value)

        if self._value is not None:
            value = self._value
        elif self._valuestring is not None or self._image:
            value = self._value = self._parse_value()
        else:
            if self._keyword == '':
                self._value = value = ''
            else:
                self._value = value = UNDEFINED

        if conf.strip_header_whitespace and isinstance(value, str):
            value = value.rstrip()

        return value

    @value.setter
    def value(self, value):
        if self._invalid:
            raise ValueError(
                'The value of invalid/unparseable cards cannot set.  Either '
                'delete this card from the header or replace it.')

        if value is None:
            value = UNDEFINED

        try:
            oldvalue = self.value
        except VerifyError:
            # probably a parsing error, falling back to the internal _value
            # which should be None. This may happen while calling _fix_value.
            oldvalue = self._value

        if oldvalue is None:
            oldvalue = UNDEFINED

        if not isinstance(value,
                          (str, int, float, complex, bool, Undefined,
                           np.floating, np.integer, np.complexfloating,
                           np.bool_)):
            raise ValueError('Illegal value: {!r}.'.format(value))

        if isinstance(value, float) and (np.isnan(value) or np.isinf(value)):
            raise ValueError("Floating point {!r} values are not allowed "
                             "in FITS headers.".format(value))

        elif isinstance(value, str):
            m = self._ascii_text_re.match(value)
            if not m:
                raise ValueError(
                    'FITS header values must contain standard printable ASCII '
                    'characters; {!r} contains characters not representable in '
                    'ASCII or non-printable characters.'.format(value))
        elif isinstance(value, bytes):
            # Allow str, but only if they can be decoded to ASCII text; note
            # this is not even allowed on Python 3 since the `bytes` type is
            # not included in `str`.  Presently we simply don't
            # allow bytes to be assigned to headers, as doing so would too
            # easily mask potential user error
            valid = True
            try:
                text_value = value.decode('ascii')
            except UnicodeDecodeError:
                valid = False
            else:
                # Check against the printable characters regexp as well
                m = self._ascii_text_re.match(text_value)
                valid = m is not None

            if not valid:
                raise ValueError(
                    'FITS header values must contain standard printable ASCII '
                    'characters; {!r} contains characters/bytes that do not '
                    'represent printable characters in ASCII.'.format(value))
        elif isinstance(value, np.bool_):
            value = bool(value)

        if (conf.strip_header_whitespace and
            (isinstance(oldvalue, str) and isinstance(value, str))):
            # Ignore extra whitespace when comparing the new value to the old
            different = oldvalue.rstrip() != value.rstrip()
        elif isinstance(oldvalue, bool) or isinstance(value, bool):
            different = oldvalue is not value
        else:
            different = (oldvalue != value or
                         not isinstance(value, type(oldvalue)))

        if different:
            self._value = value
            self._rawvalue = None
            self._modified = True
            self._valuestring = None
            self._valuemodified = True
            if self.field_specifier:
                try:
                    self._value = _int_or_float(self._value)
                except ValueError:
                    raise ValueError('value {} is not a float'.format(
                            self._value))

    @value.deleter
    def value(self):
        if self._invalid:
            raise ValueError(
                'The value of invalid/unparseable cards cannot deleted.  '
                'Either delete this card from the header or replace it.')

        if not self.field_specifier:
            self.value = ''
        else:
            raise AttributeError('Values cannot be deleted from record-valued '
                                 'keyword cards')

    @property
    def rawkeyword(self):
        """On record-valued keyword cards this is the name of the standard <= 8
        character FITS keyword that this RVKC is stored in.  Otherwise it is
        the card's normal keyword.
        """

        if self._rawkeyword is not None:
            return self._rawkeyword
        elif self.field_specifier is not None:
            self._rawkeyword = self.keyword.split('.', 1)[0]
            return self._rawkeyword
        else:
            return self.keyword

    @property
    def rawvalue(self):
        """On record-valued keyword cards this is the raw string value in
        the ``<field-specifier>: <value>`` format stored in the card in order
        to represent a RVKC.  Otherwise it is the card's normal value.
        """

        if self._rawvalue is not None:
            return self._rawvalue
        elif self.field_specifier is not None:
            self._rawvalue = '{}: {}'.format(self.field_specifier, self.value)
            return self._rawvalue
        else:
            return self.value

    @property
    def comment(self):
        """Get the comment attribute from the card image if not already set."""

        if self._comment is not None:
            return self._comment
        elif self._image:
            self._comment = self._parse_comment()
            return self._comment
        else:
            self._comment = ''
            return ''

    @comment.setter
    def comment(self, comment):
        if self._invalid:
            raise ValueError(
                'The comment of invalid/unparseable cards cannot set.  Either '
                'delete this card from the header or replace it.')

        if comment is None:
            comment = ''

        if isinstance(comment, str):
            m = self._ascii_text_re.match(comment)
            if not m:
                raise ValueError(
                    'FITS header comments must contain standard printable '
                    'ASCII characters; {!r} contains characters not '
                    'representable in ASCII or non-printable characters.'
                    .format(comment))

        try:
            oldcomment = self.comment
        except VerifyError:
            # probably a parsing error, falling back to the internal _comment
            # which should be None.
            oldcomment = self._comment

        if oldcomment is None:
            oldcomment = ''
        if comment != oldcomment:
            self._comment = comment
            self._modified = True

    @comment.deleter
    def comment(self):
        if self._invalid:
            raise ValueError(
                'The comment of invalid/unparseable cards cannot deleted.  '
                'Either delete this card from the header or replace it.')

        self.comment = ''

    @property
    def field_specifier(self):
        """
        The field-specifier of record-valued keyword cards; always `None` on
        normal cards.
        """

        # Ensure that the keyword exists and has been parsed--the will set the
        # internal _field_specifier attribute if this is a RVKC.
        if self.keyword:
            return self._field_specifier
        else:
            return None

    @field_specifier.setter
    def field_specifier(self, field_specifier):
        if not field_specifier:
            raise ValueError('The field-specifier may not be blank in '
                             'record-valued keyword cards.')
        elif not self.field_specifier:
            raise AttributeError('Cannot coerce cards to be record-valued '
                                 'keyword cards by setting the '
                                 'field_specifier attribute')
        elif field_specifier != self.field_specifier:
            self._field_specifier = field_specifier
            # The keyword need also be updated
            keyword = self._keyword.split('.', 1)[0]
            self._keyword = '.'.join([keyword, field_specifier])
            self._modified = True

    @field_specifier.deleter
    def field_specifier(self):
        raise AttributeError('The field_specifier attribute may not be '
                             'deleted from record-valued keyword cards.')

    @property
    def image(self):
        """
        The card "image", that is, the 80 byte character string that represents
        this card in an actual FITS header.
        """

        if self._image and not self._verified:
            self.verify('fix+warn')
        if self._image is None or self._modified:
            self._image = self._format_image()
        return self._image

    @property
    def is_blank(self):
        """
        `True` if the card is completely blank--that is, it has no keyword,
        value, or comment.  It appears in the header as 80 spaces.

        Returns `False` otherwise.
        """

        if not self._verified:
            # The card image has not been parsed yet; compare directly with the
            # string representation of a blank card
            return self._image == BLANK_CARD

        # If the keyword, value, and comment are all empty (for self.value
        # explicitly check that it is a string value, since a blank value is
        # returned as '')
        return (not self.keyword and
                (isinstance(self.value, str) and not self.value) and
                not self.comment)

    @classmethod
    def fromstring(cls, image):
        """
        Construct a `Card` object from a (raw) string. It will pad the string
        if it is not the length of a card image (80 columns).  If the card
        image is longer than 80 columns, assume it contains ``CONTINUE``
        card(s).
        """

        card = cls()
        card._image = _pad(image)
        card._verified = False
        return card

    @classmethod
    def normalize_keyword(cls, keyword):
        """
        `classmethod` to convert a keyword value that may contain a
        field-specifier to uppercase.  The effect is to raise the key to
        uppercase and leave the field specifier in its original case.

        Parameters
        ----------
        keyword : or str
            A keyword value or a ``keyword.field-specifier`` value
        """

        # Test first for the most common case: a standard FITS keyword provided
        # in standard all-caps
        if (len(keyword) <= KEYWORD_LENGTH and
                cls._keywd_FSC_RE.match(keyword)):
            return keyword

        # Test if this is a record-valued keyword
        match = cls._rvkc_keyword_name_RE.match(keyword)

        if match:
            return '.'.join((match.group('keyword').strip().upper(),
                             match.group('field_specifier')))
        elif len(keyword) > 9 and keyword[:9].upper() == 'HIERARCH ':
            # Remove 'HIERARCH' from HIERARCH keywords; this could lead to
            # ambiguity if there is actually a keyword card containing
            # "HIERARCH HIERARCH", but shame on you if you do that.
            return keyword[9:].strip().upper()
        else:
            # A normal FITS keyword, but provided in non-standard case
            return keyword.strip().upper()

    def _check_if_rvkc(self, *args):
        """
        Determine whether or not the card is a record-valued keyword card.

        If one argument is given, that argument is treated as a full card image
        and parsed as such.  If two arguments are given, the first is treated
        as the card keyword (including the field-specifier if the card is
        intended as a RVKC), and the second as the card value OR the first value
        can be the base keyword, and the second value the 'field-specifier:
        value' string.

        If the check passes the ._keyword, ._value, and .field_specifier
        keywords are set.

        Examples
        --------

        ::

            self._check_if_rvkc('DP1', 'AXIS.1: 2')
            self._check_if_rvkc('DP1.AXIS.1', 2)
            self._check_if_rvkc('DP1     = AXIS.1: 2')
        """

        if not conf.enable_record_valued_keyword_cards:
            return False

        if len(args) == 1:
            return self._check_if_rvkc_image(*args)
        elif len(args) == 2:
            keyword, value = args
            if not isinstance(keyword, str):
                return False
            if keyword in self._commentary_keywords:
                return False
            match = self._rvkc_keyword_name_RE.match(keyword)
            if match and isinstance(value, (int, float)):
                self._init_rvkc(match.group('keyword'),
                                match.group('field_specifier'), None, value)
                return True

            # Testing for ': ' is a quick way to avoid running the full regular
            # expression, speeding this up for the majority of cases
            if isinstance(value, str) and value.find(': ') > 0:
                match = self._rvkc_field_specifier_val_RE.match(value)
                if match and self._keywd_FSC_RE.match(keyword):
                    self._init_rvkc(keyword, match.group('keyword'), value,
                                    match.group('val'))
                    return True

    def _check_if_rvkc_image(self, *args):
        """
        Implements `Card._check_if_rvkc` for the case of an unparsed card
        image.  If given one argument this is the full intact image.  If given
        two arguments the card has already been split between keyword and
        value+comment at the standard value indicator '= '.
        """

        if len(args) == 1:
            image = args[0]
            eq_idx = image.find(VALUE_INDICATOR)
            if eq_idx < 0 or eq_idx > 9:
                return False
            keyword = image[:eq_idx]
            rest = image[eq_idx + VALUE_INDICATOR_LEN:]
        else:
            keyword, rest = args

        rest = rest.lstrip()

        # This test allows us to skip running the full regular expression for
        # the majority of cards that do not contain strings or that definitely
        # do not contain RVKC field-specifiers; it's very much a
        # micro-optimization but it does make a measurable difference
        if not rest or rest[0] != "'" or rest.find(': ') < 2:
            return False

        match = self._rvkc_keyword_val_comm_RE.match(rest)
        if match:
            self._init_rvkc(keyword, match.group('keyword'),
                            match.group('rawval'), match.group('val'))
            return True

    def _init_rvkc(self, keyword, field_specifier, field, value):
        """
        Sort of addendum to Card.__init__ to set the appropriate internal
        attributes if the card was determined to be a RVKC.
        """

        keyword_upper = keyword.upper()
        self._keyword = '.'.join((keyword_upper, field_specifier))
        self._rawkeyword = keyword_upper
        self._field_specifier = field_specifier
        self._value = _int_or_float(value)
        self._rawvalue = field

    def _parse_keyword(self):
        keyword = self._image[:KEYWORD_LENGTH].strip()
        keyword_upper = keyword.upper()

        if keyword_upper in self._special_keywords:
            return keyword_upper
        elif (keyword_upper == 'HIERARCH' and self._image[8] == ' ' and
              HIERARCH_VALUE_INDICATOR in self._image):
            # This is valid HIERARCH card as described by the HIERARCH keyword
            # convention:
            # http://fits.gsfc.nasa.gov/registry/hierarch_keyword.html
            self._hierarch = True
            self._value_indicator = HIERARCH_VALUE_INDICATOR
            keyword = self._image.split(HIERARCH_VALUE_INDICATOR, 1)[0][9:]
            return keyword.strip()
        else:
            val_ind_idx = self._image.find(VALUE_INDICATOR)
            if 0 <= val_ind_idx <= KEYWORD_LENGTH:
                # The value indicator should appear in byte 8, but we are
                # flexible and allow this to be fixed
                if val_ind_idx < KEYWORD_LENGTH:
                    keyword = keyword[:val_ind_idx]
                    keyword_upper = keyword_upper[:val_ind_idx]

                rest = self._image[val_ind_idx + VALUE_INDICATOR_LEN:]

                # So far this looks like a standard FITS keyword; check whether
                # the value represents a RVKC; if so then we pass things off to
                # the RVKC parser
                if self._check_if_rvkc_image(keyword, rest):
                    return self._keyword

                return keyword_upper
            else:
                warnings.warn(
                    'The following header keyword is invalid or follows an '
                    'unrecognized non-standard convention:\n{}'
                    .format(self._image), AstropyUserWarning)
                self._invalid = True
                return keyword

    def _parse_value(self):
        """Extract the keyword value from the card image."""

        # for commentary cards, no need to parse further
        # Likewise for invalid cards
        if self.keyword.upper() in self._commentary_keywords or self._invalid:
            return self._image[KEYWORD_LENGTH:].rstrip()

        if self._check_if_rvkc(self._image):
            return self._value

        if len(self._image) > self.length:
            values = []
            for card in self._itersubcards():
                value = card.value.rstrip().replace("''", "'")
                if value and value[-1] == '&':
                    value = value[:-1]
                values.append(value)

            value = ''.join(values)

            self._valuestring = value
            return value

        m = self._value_NFSC_RE.match(self._split()[1])

        if m is None:
            raise VerifyError("Unparsable card ({}), fix it first with "
                              ".verify('fix').".format(self.keyword))

        if m.group('bool') is not None:
            value = m.group('bool') == 'T'
        elif m.group('strg') is not None:
            value = re.sub("''", "'", m.group('strg'))
        elif m.group('numr') is not None:
            #  Check for numbers with leading 0s.
            numr = self._number_NFSC_RE.match(m.group('numr'))
            digt = translate(numr.group('digt'), FIX_FP_TABLE2, ' ')
            if numr.group('sign') is None:
                sign = ''
            else:
                sign = numr.group('sign')
            value = _str_to_num(sign + digt)

        elif m.group('cplx') is not None:
            #  Check for numbers with leading 0s.
            real = self._number_NFSC_RE.match(m.group('real'))
            rdigt = translate(real.group('digt'), FIX_FP_TABLE2, ' ')
            if real.group('sign') is None:
                rsign = ''
            else:
                rsign = real.group('sign')
            value = _str_to_num(rsign + rdigt)
            imag = self._number_NFSC_RE.match(m.group('imag'))
            idigt = translate(imag.group('digt'), FIX_FP_TABLE2, ' ')
            if imag.group('sign') is None:
                isign = ''
            else:
                isign = imag.group('sign')
            value += _str_to_num(isign + idigt) * 1j
        else:
            value = UNDEFINED

        if not self._valuestring:
            self._valuestring = m.group('valu')
        return value

    def _parse_comment(self):
        """Extract the keyword value from the card image."""

        # for commentary cards, no need to parse further
        # likewise for invalid/unparseable cards
        if self.keyword in Card._commentary_keywords or self._invalid:
            return ''

        if len(self._image) > self.length:
            comments = []
            for card in self._itersubcards():
                if card.comment:
                    comments.append(card.comment)
            comment = '/ ' + ' '.join(comments).rstrip()
            m = self._value_NFSC_RE.match(comment)
        else:
            m = self._value_NFSC_RE.match(self._split()[1])

        if m is not None:
            comment = m.group('comm')
            if comment:
                return comment.rstrip()
        return ''

    def _split(self):
        """
        Split the card image between the keyword and the rest of the card.
        """

        if self._image is not None:
            # If we already have a card image, don't try to rebuild a new card
            # image, which self.image would do
            image = self._image
        else:
            image = self.image

        if self.keyword in self._special_keywords:
            keyword, valuecomment = image.split(' ', 1)
        else:
            try:
                delim_index = image.index(self._value_indicator)
            except ValueError:
                delim_index = None

            # The equal sign may not be any higher than column 10; anything
            # past that must be considered part of the card value
            if delim_index is None:
                keyword = image[:KEYWORD_LENGTH]
                valuecomment = image[KEYWORD_LENGTH:]
            elif delim_index > 10 and image[:9] != 'HIERARCH ':
                keyword = image[:8]
                valuecomment = image[8:]
            else:
                keyword, valuecomment = image.split(self._value_indicator, 1)
        return keyword.strip(), valuecomment.strip()

    def _fix_keyword(self):
        if self.field_specifier:
            keyword, field_specifier = self._keyword.split('.', 1)
            self._keyword = '.'.join([keyword.upper(), field_specifier])
        else:
            self._keyword = self._keyword.upper()
        self._modified = True

    def _fix_value(self):
        """Fix the card image for fixable non-standard compliance."""

        value = None
        keyword, valuecomment = self._split()
        m = self._value_NFSC_RE.match(valuecomment)

        # for the unparsable case
        if m is None:
            try:
                value, comment = valuecomment.split('/', 1)
                self.value = value.strip()
                self.comment = comment.strip()
            except (ValueError, IndexError):
                self.value = valuecomment
            self._valuestring = self._value
            return
        elif m.group('numr') is not None:
            numr = self._number_NFSC_RE.match(m.group('numr'))
            value = translate(numr.group('digt'), FIX_FP_TABLE, ' ')
            if numr.group('sign') is not None:
                value = numr.group('sign') + value

        elif m.group('cplx') is not None:
            real = self._number_NFSC_RE.match(m.group('real'))
            rdigt = translate(real.group('digt'), FIX_FP_TABLE, ' ')
            if real.group('sign') is not None:
                rdigt = real.group('sign') + rdigt

            imag = self._number_NFSC_RE.match(m.group('imag'))
            idigt = translate(imag.group('digt'), FIX_FP_TABLE, ' ')
            if imag.group('sign') is not None:
                idigt = imag.group('sign') + idigt
            value = '({}, {})'.format(rdigt, idigt)
        self._valuestring = value
        # The value itself has not been modified, but its serialized
        # representation (as stored in self._valuestring) has been changed, so
        # still set this card as having been modified (see ticket #137)
        self._modified = True

    def _format_keyword(self):
        if self.keyword:
            if self.field_specifier:
                return '{:{len}}'.format(self.keyword.split('.', 1)[0],
                                         len=KEYWORD_LENGTH)
            elif self._hierarch:
                return 'HIERARCH {} '.format(self.keyword)
            else:
                return '{:{len}}'.format(self.keyword, len=KEYWORD_LENGTH)
        else:
            return ' ' * KEYWORD_LENGTH

    def _format_value(self):
        # value string
        float_types = (float, np.floating, complex, np.complexfloating)

        # Force the value to be parsed out first
        value = self.value
        # But work with the underlying raw value instead (to preserve
        # whitespace, for now...)
        value = self._value

        if self.keyword in self._commentary_keywords:
            # The value of a commentary card must be just a raw unprocessed
            # string
            value = str(value)
        elif (self._valuestring and not self._valuemodified and
              isinstance(self.value, float_types)):
            # Keep the existing formatting for float/complex numbers
            value = '{:>20}'.format(self._valuestring)
        elif self.field_specifier:
            value = _format_value(self._value).strip()
            value = "'{}: {}'".format(self.field_specifier, value)
        else:
            value = _format_value(value)

        # For HIERARCH cards the value should be shortened to conserve space
        if not self.field_specifier and len(self.keyword) > KEYWORD_LENGTH:
            value = value.strip()

        return value

    def _format_comment(self):
        if not self.comment:
            return ''
        else:
            return ' / {}'.format(self._comment)

    def _format_image(self):
        keyword = self._format_keyword()

        value = self._format_value()
        is_commentary = keyword.strip() in self._commentary_keywords
        if is_commentary:
            comment = ''
        else:
            comment = self._format_comment()

        # equal sign string
        # by default use the standard value indicator even for HIERARCH cards;
        # later we may abbreviate it if necessary
        delimiter = VALUE_INDICATOR
        if is_commentary:
            delimiter = ''

        # put all parts together
        output = ''.join([keyword, delimiter, value, comment])

        # For HIERARCH cards we can save a bit of space if necessary by
        # removing the space between the keyword and the equals sign; I'm
        # guessing this is part of the HIEARCH card specification
        keywordvalue_length = len(keyword) + len(delimiter) + len(value)
        if (keywordvalue_length > self.length and
                keyword.startswith('HIERARCH')):
            if (keywordvalue_length == self.length + 1 and keyword[-1] == ' '):
                output = ''.join([keyword[:-1], delimiter, value, comment])
            else:
                # I guess the HIERARCH card spec is incompatible with CONTINUE
                # cards
                raise ValueError('The header keyword {!r} with its value is '
                                 'too long'.format(self.keyword))

        if len(output) <= self.length:
            output = '{:80}'.format(output)
        else:
            # longstring case (CONTINUE card)
            # try not to use CONTINUE if the string value can fit in one line.
            # Instead, just truncate the comment
            if (isinstance(self.value, str) and
                len(value) > (self.length - 10)):
                output = self._format_long_image()
            else:
                warnings.warn('Card is too long, comment will be truncated.',
                              VerifyWarning)
                output = output[:Card.length]
        return output

    def _format_long_image(self):
        """
        Break up long string value/comment into ``CONTINUE`` cards.
        This is a primitive implementation: it will put the value
        string in one block and the comment string in another.  Also,
        it does not break at the blank space between words.  So it may
        not look pretty.
        """

        if self.keyword in Card._commentary_keywords:
            return self._format_long_commentary_image()

        value_length = 67
        comment_length = 64
        output = []

        # do the value string
        value = self._value.replace("'", "''")
        words = _words_group(value, value_length)
        for idx, word in enumerate(words):
            if idx == 0:
                headstr = '{:{len}}= '.format(self.keyword, len=KEYWORD_LENGTH)
            else:
                headstr = 'CONTINUE  '

            # If this is the final CONTINUE remove the '&'
            if not self.comment and idx == len(words) - 1:
                value_format = "'{}'"
            else:
                value_format = "'{}&'"

            value = valu
```


# astropy/io/fits/tests (the files in it)

astropy/io/fits/tests/__init__.py
astropy/io/fits/tests/cfitsio_verify.c
astropy/io/fits/tests/data/arange.fits
astropy/io/fits/tests/data/ascii.fits
astropy/io/fits/tests/data/blank.fits
astropy/io/fits/tests/data/btable.fits
astropy/io/fits/tests/data/chandra_time.fits
astropy/io/fits/tests/data/checksum.fits
astropy/io/fits/tests/data/comp.fits
astropy/io/fits/tests/data/compressed_float_bzero.fits
astropy/io/fits/tests/data/compressed_image.fits
astropy/io/fits/tests/data/fixed-1890.fits
astropy/io/fits/tests/data/group.fits
astropy/io/fits/tests/data/history_header.fits
astropy/io/fits/tests/data/memtest.fits
astropy/io/fits/tests/data/o4sp040b0_raw.fits
astropy/io/fits/tests/data/random_groups.fits
astropy/io/fits/tests/data/scale.fits
astropy/io/fits/tests/data/stddata.fits
astropy/io/fits/tests/data/table.fits
astropy/io/fits/tests/data/tb.fits
astropy/io/fits/tests/data/tdim.fits
astropy/io/fits/tests/data/test0.fits
astropy/io/fits/tests/data/test1.fits
astropy/io/fits/tests/data/variable_length_table.fits
astropy/io/fits/tests/data/zerowidth.fits
astropy/io/fits/tests/test_checksum.py
astropy/io/fits/tests/test_compression_failures.py
astropy/io/fits/tests/test_connect.py
astropy/io/fits/tests/test_convenience.py
astropy/io/fits/tests/test_core.py
astropy/io/fits/tests/test_diff.py
astropy/io/fits/tests/test_division.py
astropy/io/fits/tests/test_fitscheck.py
astropy/io/fits/tests/test_fitsdiff.py
astropy/io/fits/tests/test_fitsheader.py
astropy/io/fits/tests/test_fitsinfo.py
astropy/io/fits/tests/test_fitstime.py
astropy/io/fits/tests/test_groups.py
astropy/io/fits/tests/test_hdulist.py
astropy/io/fits/tests/test_header.py
astropy/io/fits/tests/test_image.py
astropy/io/fits/tests/test_nonstandard.py
astropy/io/fits/tests/test_structured.py
astropy/io/fits/tests/test_table.py
astropy/io/fits/tests/test_uint.py
astropy/io/fits/tests/test_util.py


# The last commit

```
7b678175a SWE-bench


```

```diff

```
````

### `direct-check.log`

```
check: python -m pytest astropy/io/fits/tests/test_header.py
============================= test session starts ==============================
platform linux -- Python 3.9.20, pytest-7.1.2, pluggy-1.3.0
Matplotlib: 3.9.2
Freetype: 2.6.1

Running tests with Astropy version 4.0.dev24591.
Running tests in astropy/io/fits/tests/test_header.py.

Date: 2026-11-06T10:49:07

Platform: Linux-7.0.0-1014-gcp-x86_64-with-glibc2.35

Executable: /opt/miniconda3/envs/testbed/bin/python

Full Python Version: 
3.9.20 (main, Oct  3 2024, 07:27:41) 
[GCC 11.2.0]

encodings: sys: utf-8, locale: UTF-8, filesystem: utf-8
byteorder: little
float info: dig: 15, mant_dig: 15

Numpy: 1.25.2
Scipy: not available
Matplotlib: 3.9.2
h5py: not available
Pandas: not available
Cython: not available
Scikit-image: not available
astropy_helpers: 3.2rc1
Using Astropy options: remote_data: none.

rootdir: /testbed, configfile: setup.cfg
plugins: doctestplus-1.0.0, remotedata-0.4.0, xdist-3.3.1, mpl-0.17.0, cov-4.1.0, openfiles-0.5.0, arraydiff-0.5.0, hypothesis-6.82.6, astropy-header-0.2.2, mock-3.11.1, filter-subpackage-0.1.2, astropy-0.10.0
collected 152 items

astropy/io/fits/tests/test_header.py ................................... [ 23%]
........................................................................ [ 70%]
.......................................FF....                            [100%]

=================================== FAILURES ===================================
_____________ TestRecordValuedKeywordCards.test_fitsheader_script ______________

self = <[AttributeError("module 'numpy' has no attribute 'int'.\n`np.int` was a deprecated alias for the builtin `int`. To av... https://numpy.org/devdocs/release/1.20.0-notes.html#deprecations") raised in repr()] HDUList object at 0x74970f134310>
func = <built-in method __getitem__ of HDUList object at 0x74970f134310>
args = (1,), kwargs = {}

    def _try_while_unread_hdus(self, func, *args, **kwargs):
        """
        Attempt an operation that accesses an HDU by index/name
        that can fail if not all HDUs have been read yet.  Keep
        reading HDUs until the operation succeeds or there are no
        more HDUs to read.
        """
    
        while True:
            try:
>               return func(*args, **kwargs)
E               IndexError: list index out of range

astropy/io/fits/hdu/hdulist.py:1096: IndexError

During handling of the above exception, another exception occurred:

self = <astropy.io.fits.tests.test_header.TestRecordValuedKeywordCards object at 0x74970f2145b0>

    def test_fitsheader_script(self):
        """Tests the basic functionality of the `fitsheader` script."""
        from astropy.io.fits.scripts import fitsheader
    
        # Can an extension by specified by the EXTNAME keyword?
        hf = fitsheader.HeaderFormatter(self.data('zerowidth.fits'))
>       output = hf.parse(extensions=['AIPS FQ'])

astropy/io/fits/tests/test_header.py:2744: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
astropy/io/fits/scripts/fitsheader.py:146: in parse
    return self._parse_internal(hdukeys, keywords, compressed)
astropy/io/fits/scripts/fitsheader.py:154: in _parse_internal
    cards = self._get_cards(hdu, keywords, compressed)
astropy/io/fits/scripts/fitsheader.py:195: in _get_cards
    header = self._hdulist[hdukey].header
astropy/io/fits/hdu/hdulist.py:300: in __getitem__
    self._positive_index_of(key))
astropy/io/fits/hdu/hdulist.py:754: in _positive_index_of
    index = self.index_of(key)
astropy/io/fits/hdu/hdulist.py:724: in index_of
    for idx, hdu in enumerate(self):
astropy/io/fits/hdu/hdulist.py:247: in __iter__
    yield self[idx]
astropy/io/fits/hdu/hdulist.py:299: in __getitem__
    return self._try_while_unread_hdus(super().__getitem__,
astropy/io/fits/hdu/hdulist.py:1098: in _try_while_unread_hdus
    if self._read_next_hdu():
astropy/io/fits/hdu/hdulist.py:1139: in _read_next_hdu
    hdu = _BaseHDU.readfrom(fileobj, **kwargs)
astropy/io/fits/hdu/base.py:315: in readfrom
    hdu = cls._readfrom_internal(fileobj, checksum=checksum,
astropy/io/fits/hdu/base.py:444: in _readfrom_internal
    hdu = cls(data=DELAYED, header=header, **new_kwargs)
astropy/io/fits/hdu/table.py:843: in __init__
    from astropy.table import Table
astropy/table/__init__.py:41: in <module>
    from .column import Column, MaskedColumn, StringTruncateWarning, ColumnInfo
astropy/table/column.py:28: in <module>
    from .np_utils import fix_column_name
astropy/table/np_utils.py:16: in <module>
    from . import _np_utils
astropy/table/_np_utils.pyx:15: in init astropy.table._np_utils
    DTYPE = np.int
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

attr = 'int'

    def __getattr__(attr):
        # Warn for expired attributes, and return a dummy function
        # that always raises an exception.
        import warnings
        import math
        try:
            msg = __expired_functions__[attr]
        except KeyError:
            pass
        else:
            warnings.warn(msg, DeprecationWarning, stacklevel=2)
    
            def _expired(*args, **kwds):
                raise RuntimeError(msg)
    
            return _expired
    
        # Emit warnings for deprecated attributes
        try:
            val, msg = __deprecated_attrs__[attr]
        except KeyError:
            pass
        else:
            warnings.warn(msg, DeprecationWarning, stacklevel=2)
            return val
    
        if attr in __future_scalars__:
            # And future warnings for those that will change, but also give
            # the AttributeError
            warnings.warn(
                f"In the future `np.{attr}` will be defined as the "
                "corresponding NumPy scalar.", FutureWarning, stacklevel=2)
    
        if attr in __former_attrs__:
>           raise AttributeError(__former_attrs__[attr])
E           AttributeError: module 'numpy' has no attribute 'int'.
E           `np.int` was a deprecated alias for the builtin `int`. To avoid this error in existing code, use `int` by itself. Doing this will not modify any behavior and is safe. When replacing `np.int`, you may wish to use e.g. `np.int64` or `np.int32` to specify the precision. If you wish to review your current use, check the release note link for additional information.
E           The aliases was originally deprecated in NumPy 1.20; for more details and guidance see the original release note at:
E               https://numpy.org/devdocs/release/1.20.0-notes.html#deprecations

/opt/miniconda3/envs/testbed/lib/python3.9/site-packages/numpy/__init__.py:319: AttributeError
__________ TestRecordValuedKeywordCards.test_fitsheader_table_feature __________

self = <astropy.io.fits.tests.test_header.TestRecordValuedKeywordCards object at 0x74970f214700>

    def test_fitsheader_table_feature(self):
        """Tests the `--table` feature of the `fitsheader` script."""
        from astropy.io import fits
        from astropy.io.fits.scripts import fitsheader
        test_filename = self.data('zerowidth.fits')
        fitsobj = fits.open(test_filename)
        formatter = fitsheader.TableHeaderFormatter(test_filename)
    
        # Does the table contain the expected number of rows?
>       mytable = formatter.parse([0])

astropy/io/fits/tests/test_header.py:2787: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
astropy/io/fits/scripts/fitsheader.py:146: in parse
    return self._parse_internal(hdukeys, keywords, compressed)
astropy/io/fits/scripts/fitsheader.py:246: in _parse_internal
    from astropy import table
astropy/table/__init__.py:41: in <module>
    from .column import Column, MaskedColumn, StringTruncateWarning, ColumnInfo
astropy/table/column.py:28: in <module>
    from .np_utils import fix_column_name
astropy/table/np_utils.py:16: in <module>
    from . import _np_utils
astropy/table/_np_utils.pyx:15: in init astropy.table._np_utils
    DTYPE = np.int
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

attr = 'int'

    def __getattr__(attr):
        # Warn for expired attributes, and return a dummy function
        # that always raises an exception.
        import warnings
        import math
        try:
            msg = __expired_functions__[attr]
        except KeyError:
            pass
        else:
            warnings.warn(msg, DeprecationWarning, stacklevel=2)
    
            def _expired(*args, **kwds):
                raise RuntimeError(msg)
    
            return _expired
    
        # Emit warnings for deprecated attributes
        try:
            val, msg = __deprecated_attrs__[attr]
        except KeyError:
            pass
        else:
            warnings.warn(msg, DeprecationWarning, stacklevel=2)
            return val
    
        if attr in __future_scalars__:
            # And future warnings for those that will change, but also give
            # the AttributeError
            warnings.warn(
                f"In the future `np.{attr}` will be defined as the "
                "corresponding NumPy scalar.", FutureWarning, stacklevel=2)
    
        if attr in __former_attrs__:
>           raise AttributeError(__former_attrs__[attr])
E           AttributeError: module 'numpy' has no attribute 'int'.
E           `np.int` was a deprecated alias for the builtin `int`. To avoid this error in existing code, use `int` by itself. Doing this will not modify any behavior and is safe. When replacing `np.int`, you may wish to use e.g. `np.int64` or `np.int32` to specify the precision. If you wish to review your current use, check the release note link for additional information.
E           The aliases was originally deprecated in NumPy 1.20; for more details and guidance see the original release note at:
E               https://numpy.org/devdocs/release/1.20.0-notes.html#deprecations

/opt/miniconda3/envs/testbed/lib/python3.9/site-packages/numpy/__init__.py:319: AttributeError
=========================== short test summary info ============================
FAILED astropy/io/fits/tests/test_header.py::TestRecordValuedKeywordCards::test_fitsheader_script
FAILED astropy/io/fits/tests/test_header.py::TestRecordValuedKeywordCards::test_fitsheader_table_feature
======================== 2 failed, 150 passed in 1.38s =========================

the Check also fails on the tree as the run found it (baseline-check.log): nothing it says counts, the judge decides
scope: astropy/io/fits/header.py astropy/io/fits/card.py astropy/io/fits/tests
OUTSIDE THE SCOPE: CHANGES.rst +3 -0 (undo it: git checkout the file, or delete it when the run made it)
changed: astropy/io/fits/card.py +7 -5
changed: astropy/io/fits/header.py +9 -3
changed: astropy/io/fits/tests/test_header.py +26 -0
```

### `direct-status.txt`

```
0
```

### `direct.patch`

```diff
diff --git a/CHANGES.rst b/CHANGES.rst
index 3dc79416e..2366449a4 100644
--- a/CHANGES.rst
+++ b/CHANGES.rst
@@ -181,6 +181,9 @@ astropy.io.misc
 astropy.io.fits
 ^^^^^^^^^^^^^^^
 
+``Header.fromstring`` and ``Card.fromstring`` now accept both ``str`` and
+``bytes`` input on Python 3. [#4970]
+
 astropy.io.registry
 ^^^^^^^^^^^^^^^^^^^
 
diff --git a/astropy/io/fits/card.py b/astropy/io/fits/card.py
index 8c1ac5d73..d3fee8550 100644
--- a/astropy/io/fits/card.py
+++ b/astropy/io/fits/card.py
@@ -5,7 +5,7 @@ import warnings
 
 import numpy as np
 
-from .util import _str_to_num, _is_int, translate, _words_group
+from .util import _str_to_num, _is_int, translate, _words_group, decode_ascii
 from .verify import _Verify, _ErrList, VerifyError, VerifyWarning
 
 from . import conf
@@ -547,13 +547,15 @@ class Card(_Verify):
     @classmethod
     def fromstring(cls, image):
         """
-        Construct a `Card` object from a (raw) string. It will pad the string
-        if it is not the length of a card image (80 columns).  If the card
-        image is longer than 80 columns, assume it contains ``CONTINUE``
-        card(s).
+        Construct a `Card` object from a (raw) string or byte string.  It will
+        pad the string if it is not the length of a card image (80 columns).
+        If the card image is longer than 80 columns, assume it contains
+        ``CONTINUE`` card(s).
         """
 
         card = cls()
+        if isinstance(image, bytes):
+            image = decode_ascii(image)
         card._image = _pad(image)
         card._verified = False
         return card
diff --git a/astropy/io/fits/header.py b/astropy/io/fits/header.py
index ad07e6d52..6d059fbbf 100644
--- a/astropy/io/fits/header.py
+++ b/astropy/io/fits/header.py
@@ -334,10 +334,10 @@ class Header:
 
         Parameters
         ----------
-        data : str
-           String containing the entire header.
+        data : str or bytes
+           String or byte string containing the entire header.
 
-        sep : str, optional
+        sep : str or bytes, optional
             The string separating cards from each other, such as a newline.  By
             default there is no card separator (as is the case in a raw FITS
             file).
@@ -348,6 +348,12 @@ class Header:
             A new `Header` instance.
         """
 
+        if isinstance(data, bytes):
+            data = decode_ascii(data)
+
+        if isinstance(sep, bytes):
+            sep = decode_ascii(sep)
+
         cards = []
 
         # If the card separator contains characters that may validly appear in
diff --git a/astropy/io/fits/tests/test_header.py b/astropy/io/fits/tests/test_header.py
index 7c1725aed..7dccf70b5 100644
--- a/astropy/io/fits/tests/test_header.py
+++ b/astropy/io/fits/tests/test_header.py
@@ -102,6 +102,32 @@ class TestHeaderFunctions(FitsTestCase):
         c = fits.Card.fromstring('ABC     = F')
         assert c.value is False
 
+    def test_card_from_bytes(self):
+        """Regression test for https://github.com/astropy/astropy/issues/4970
+
+        `Card.fromstring` should accept both `str` and `bytes` input.
+        """
+
+        c = fits.Card.fromstring(b'ABC     = F')
+        assert c.keyword == 'ABC'
+        assert c.value is False
+        assert str(c) == _pad('ABC     = F')
+
+    def test_header_from_bytes(self):
+        """Regression test for https://github.com/astropy/astropy/issues/4970
+
+        `Header.fromstring` should accept both `str` and `bytes` input.
+        """
+
+        hstr = b"FOCALLEN= +1.550000000000e+002\nAPERTURE= +0.000000000000e+000"
+        h = fits.Header.fromstring(hstr, sep=b'\n')
+        assert h['FOCALLEN'] == 155.0
+        assert h['APERTURE'] == 0.0
+
+        h = fits.Header.fromstring(hstr, sep='\n')
+        assert h['FOCALLEN'] == 155.0
+        assert h['APERTURE'] == 0.0
+
     def test_long_integer_value_card(self):
         """Test Card constructor with long integer value"""
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
check: python -m pytest astropy/io/fits/tests/test_header.py
============================= test session starts ==============================
platform linux -- Python 3.9.20, pytest-7.1.2, pluggy-1.3.0
Matplotlib: 3.9.2
Freetype: 2.6.1

Running tests with Astropy version 4.0.dev24591.
Running tests in astropy/io/fits/tests/test_header.py.

Date: 2026-11-06T10:50:23

Platform: Linux-7.0.0-1014-gcp-x86_64-with-glibc2.35

Executable: /opt/miniconda3/envs/testbed/bin/python

Full Python Version: 
3.9.20 (main, Oct  3 2024, 07:27:41) 
[GCC 11.2.0]

encodings: sys: utf-8, locale: UTF-8, filesystem: utf-8
byteorder: little
float info: dig: 15, mant_dig: 15

Numpy: 1.25.2
Scipy: not available
Matplotlib: 3.9.2
h5py: not available
Pandas: not available
Cython: not available
Scikit-image: not available
astropy_helpers: 3.2rc1
Using Astropy options: remote_data: none.

rootdir: /testbed, configfile: setup.cfg
plugins: doctestplus-1.0.0, remotedata-0.4.0, xdist-3.3.1, mpl-0.17.0, cov-4.1.0, openfiles-0.5.0, arraydiff-0.5.0, hypothesis-6.82.6, astropy-header-0.2.2, mock-3.11.1, filter-subpackage-0.1.2, astropy-0.10.0
collected 152 items

astropy/io/fits/tests/test_header.py ................................... [ 23%]
........................................................................ [ 70%]
.......................................FF....                            [100%]

=================================== FAILURES ===================================
_____________ TestRecordValuedKeywordCards.test_fitsheader_script ______________

self = <[AttributeError("module 'numpy' has no attribute 'int'.\n`np.int` was a deprecated alias for the builtin `int`. To av... https://numpy.org/devdocs/release/1.20.0-notes.html#deprecations") raised in repr()] HDUList object at 0x7ffb777b2360>
func = <built-in method __getitem__ of HDUList object at 0x7ffb777b2360>
args = (1,), kwargs = {}

    def _try_while_unread_hdus(self, func, *args, **kwargs):
        """
        Attempt an operation that accesses an HDU by index/name
        that can fail if not all HDUs have been read yet.  Keep
        reading HDUs until the operation succeeds or there are no
        more HDUs to read.
        """
    
        while True:
            try:
>               return func(*args, **kwargs)
E               IndexError: list index out of range

astropy/io/fits/hdu/hdulist.py:1096: IndexError

During handling of the above exception, another exception occurred:

self = <astropy.io.fits.tests.test_header.TestRecordValuedKeywordCards object at 0x7ffb778954c0>

    def test_fitsheader_script(self):
        """Tests the basic functionality of the `fitsheader` script."""
        from astropy.io.fits.scripts import fitsheader
    
        # Can an extension by specified by the EXTNAME keyword?
        hf = fitsheader.HeaderFormatter(self.data('zerowidth.fits'))
>       output = hf.parse(extensions=['AIPS FQ'])

astropy/io/fits/tests/test_header.py:2744: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
astropy/io/fits/scripts/fitsheader.py:146: in parse
    return self._parse_internal(hdukeys, keywords, compressed)
astropy/io/fits/scripts/fitsheader.py:154: in _parse_internal
    cards = self._get_cards(hdu, keywords, compressed)
astropy/io/fits/scripts/fitsheader.py:195: in _get_cards
    header = self._hdulist[hdukey].header
astropy/io/fits/hdu/hdulist.py:300: in __getitem__
    self._positive_index_of(key))
astropy/io/fits/hdu/hdulist.py:754: in _positive_index_of
    index = self.index_of(key)
astropy/io/fits/hdu/hdulist.py:724: in index_of
    for idx, hdu in enumerate(self):
astropy/io/fits/hdu/hdulist.py:247: in __iter__
    yield self[idx]
astropy/io/fits/hdu/hdulist.py:299: in __getitem__
    return self._try_while_unread_hdus(super().__getitem__,
astropy/io/fits/hdu/hdulist.py:1098: in _try_while_unread_hdus
    if self._read_next_hdu():
astropy/io/fits/hdu/hdulist.py:1139: in _read_next_hdu
    hdu = _BaseHDU.readfrom(fileobj, **kwargs)
astropy/io/fits/hdu/base.py:315: in readfrom
    hdu = cls._readfrom_internal(fileobj, checksum=checksum,
astropy/io/fits/hdu/base.py:444: in _readfrom_internal
    hdu = cls(data=DELAYED, header=header, **new_kwargs)
astropy/io/fits/hdu/table.py:843: in __init__
    from astropy.table import Table
astropy/table/__init__.py:41: in <module>
    from .column import Column, MaskedColumn, StringTruncateWarning, ColumnInfo
astropy/table/column.py:28: in <module>
    from .np_utils import fix_column_name
astropy/table/np_utils.py:16: in <module>
    from . import _np_utils
astropy/table/_np_utils.pyx:15: in init astropy.table._np_utils
    DTYPE = np.int
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

attr = 'int'

    def __getattr__(attr):
        # Warn for expired attributes, and return a dummy function
        # that always raises an exception.
        import warnings
        import math
        try:
            msg = __expired_functions__[attr]
        except KeyError:
            pass
        else:
            warnings.warn(msg, DeprecationWarning, stacklevel=2)
    
            def _expired(*args, **kwds):
                raise RuntimeError(msg)
    
            return _expired
    
        # Emit warnings for deprecated attributes
        try:
            val, msg = __deprecated_attrs__[attr]
        except KeyError:
            pass
        else:
            warnings.warn(msg, DeprecationWarning, stacklevel=2)
            return val
    
        if attr in __future_scalars__:
            # And future warnings for those that will change, but also give
            # the AttributeError
            warnings.warn(
                f"In the future `np.{attr}` will be defined as the "
                "corresponding NumPy scalar.", FutureWarning, stacklevel=2)
    
        if attr in __former_attrs__:
>           raise AttributeError(__former_attrs__[attr])
E           AttributeError: module 'numpy' has no attribute 'int'.
E           `np.int` was a deprecated alias for the builtin `int`. To avoid this error in existing code, use `int` by itself. Doing this will not modify any behavior and is safe. When replacing `np.int`, you may wish to use e.g. `np.int64` or `np.int32` to specify the precision. If you wish to review your current use, check the release note link for additional information.
E           The aliases was originally deprecated in NumPy 1.20; for more details and guidance see the original release note at:
E               https://numpy.org/devdocs/release/1.20.0-notes.html#deprecations

/opt/miniconda3/envs/testbed/lib/python3.9/site-packages/numpy/__init__.py:319: AttributeError
__________ TestRecordValuedKeywordCards.test_fitsheader_table_feature __________

self = <astropy.io.fits.tests.test_header.TestRecordValuedKeywordCards object at 0x7ffb77895610>

    def test_fitsheader_table_feature(self):
        """Tests the `--table` feature of the `fitsheader` script."""
        from astropy.io import fits
        from astropy.io.fits.scripts import fitsheader
        test_filename = self.data('zerowidth.fits')
        fitsobj = fits.open(test_filename)
        formatter = fitsheader.TableHeaderFormatter(test_filename)
    
        # Does the table contain the expected number of rows?
>       mytable = formatter.parse([0])

astropy/io/fits/tests/test_header.py:2787: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
astropy/io/fits/scripts/fitsheader.py:146: in parse
    return self._parse_internal(hdukeys, keywords, compressed)
astropy/io/fits/scripts/fitsheader.py:246: in _parse_internal
    from astropy import table
astropy/table/__init__.py:41: in <module>
    from .column import Column, MaskedColumn, StringTruncateWarning, ColumnInfo
astropy/table/column.py:28: in <module>
    from .np_utils import fix_column_name
astropy/table/np_utils.py:16: in <module>
    from . import _np_utils
astropy/table/_np_utils.pyx:15: in init astropy.table._np_utils
    DTYPE = np.int
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

attr = 'int'

    def __getattr__(attr):
        # Warn for expired attributes, and return a dummy function
        # that always raises an exception.
        import warnings
        import math
        try:
            msg = __expired_functions__[attr]
        except KeyError:
            pass
        else:
            warnings.warn(msg, DeprecationWarning, stacklevel=2)
    
            def _expired(*args, **kwds):
                raise RuntimeError(msg)
    
            return _expired
    
        # Emit warnings for deprecated attributes
        try:
            val, msg = __deprecated_attrs__[attr]
        except KeyError:
            pass
        else:
            warnings.warn(msg, DeprecationWarning, stacklevel=2)
            return val
    
        if attr in __future_scalars__:
            # And future warnings for those that will change, but also give
            # the AttributeError
            warnings.warn(
                f"In the future `np.{attr}` will be defined as the "
                "corresponding NumPy scalar.", FutureWarning, stacklevel=2)
    
        if attr in __former_attrs__:
>           raise AttributeError(__former_attrs__[attr])
E           AttributeError: module 'numpy' has no attribute 'int'.
E           `np.int` was a deprecated alias for the builtin `int`. To avoid this error in existing code, use `int` by itself. Doing this will not modify any behavior and is safe. When replacing `np.int`, you may wish to use e.g. `np.int64` or `np.int32` to specify the precision. If you wish to review your current use, check the release note link for additional information.
E           The aliases was originally deprecated in NumPy 1.20; for more details and guidance see the original release note at:
E               https://numpy.org/devdocs/release/1.20.0-notes.html#deprecations

/opt/miniconda3/envs/testbed/lib/python3.9/site-packages/numpy/__init__.py:319: AttributeError
=========================== short test summary info ============================
FAILED astropy/io/fits/tests/test_header.py::TestRecordValuedKeywordCards::test_fitsheader_script
FAILED astropy/io/fits/tests/test_header.py::TestRecordValuedKeywordCards::test_fitsheader_table_feature
======================== 2 failed, 150 passed in 1.46s =========================

the Check also fails on the tree as the run found it (baseline-check.log): nothing it says counts, the judge decides
scope: astropy/io/fits/header.py astropy/io/fits/card.py astropy/io/fits/tests
OUTSIDE THE SCOPE: CHANGES.rst +3 -0 (undo it: git checkout the file, or delete it when the run made it)
changed: astropy/io/fits/card.py +7 -5
changed: astropy/io/fits/header.py +9 -3
changed: astropy/io/fits/tests/test_header.py +26 -0
```

### `final-status.txt`

```
none
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
# Notes, run 2026-11-06T104711

## Solver decision

## Review

## Repair
```

### `outline.md`

````
# The prompt

Header.fromstring does not accept Python 3 bytes
According to [the docs](http://docs.astropy.org/en/stable/_modules/astropy/io/fits/header.html#Header.fromstring), the method `Header.fromstring` "...creates an HDU header from a byte string containing the entire header data."

By "byte string" here it really means the `str` type which on Python 2 could be raw binary data, but on Python 3 explicitly is not.   In fact it does work on Python 3's unicode `str`s, but here it assumes that the data can be ASCII-encoded.

Its counterpart, `Header.fromfile` will work with files opened in text or binary mode.  So probably the simplest solution for now (as opposed to adding new methods or something like that) is to change `Header.fromstring` to accept unicode or bytes string types.

`Card.fromstring` likely needs a similar treatment.


# The files of the project

```
.astropy-root
.circleci/config.yml
.gitattributes
.gitignore
.gitmodules
.mailmap
.readthedocs.yml
.travis.yml
CHANGES.rst
CITATION
CODE_OF_CONDUCT.md
CONTRIBUTING.md
GOVERNANCE.md
LICENSE.rst
MANIFEST.in
README.rst
ah_bootstrap.py
appveyor.yml
astropy/CITATION
astropy/__init__.py
astropy/_erfa/__init__.py
astropy/_erfa/core.py.templ
astropy/_erfa/erfa_additions.h
astropy/_erfa/erfa_generator.py
astropy/_erfa/pav2pv.c
astropy/_erfa/pv2pav.c
astropy/_erfa/setup_package.py
astropy/_erfa/tests/__init__.py
astropy/_erfa/tests/test_erfa.py
astropy/_erfa/ufunc.c.templ
astropy/astropy.cfg
astropy/config/__init__.py
astropy/config/affiliated.py
astropy/config/configuration.py
astropy/config/paths.py
astropy/config/tests/__init__.py
astropy/config/tests/data/alias.cfg
astropy/config/tests/data/astropy.0.3.cfg
astropy/config/tests/data/astropy.0.3.windows.cfg
astropy/config/tests/data/deprecated.cfg
astropy/config/tests/data/empty.cfg
astropy/config/tests/data/not_empty.cfg
astropy/config/tests/test_configs.py
astropy/conftest.py
astropy/constants/__init__.py
astropy/constants/astropyconst13.py
astropy/constants/astropyconst20.py
astropy/constants/cgs.py
astropy/constants/codata2010.py
astropy/constants/codata2014.py
astropy/constants/constant.py
astropy/constants/iau2012.py
astropy/constants/iau2015.py
astropy/constants/si.py
astropy/constants/tests/__init__.py
astropy/constants/tests/test_constant.py
astropy/constants/tests/test_pickle.py
astropy/constants/tests/test_prior_version.py
astropy/constants/utils.py
astropy/convolution/__init__.py
astropy/convolution/convolve.py
astropy/convolution/core.py
astropy/convolution/kernels.py
astropy/convolution/setup_package.py
astropy/convolution/src/convolve.c
astropy/convolution/src/convolve.h
astropy/convolution/tests/__init__.py
astropy/convolution/tests/test_convolve.py
astropy/convolution/tests/test_convolve_fft.py
astropy/convolution/tests/test_convolve_kernels.py
astropy/convolution/tests/test_convolve_models.py
astropy/convolution/tests/test_convolve_nddata.py
astropy/convolution/tests/test_convolve_speeds.py
astropy/convolution/tests/test_discretize.py
astropy/convolution/tests/test_kernel_class.py
astropy/convolution/tests/test_pickle.py
astropy/convolution/utils.py
astropy/coordinates/__init__.py
astropy/coordinates/angle_lextab.py
astropy/coordinates/angle_parsetab.py
astropy/coordinates/angle_utilities.py
astropy/coordinates/angles.py
astropy/coordinates/attributes.py
astropy/coordinates/baseframe.py
astropy/coordinates/builtin_frames/__init__.py
astropy/coordinates/builtin_frames/altaz.py
astropy/coordinates/builtin_frames/baseradec.py
astropy/coordinates/builtin_frames/cirs.py
astropy/coordinates/builtin_frames/cirs_observed_transforms.py
astropy/coordinates/builtin_frames/ecliptic.py
astropy/coordinates/builtin_frames/ecliptic_transforms.py
astropy/coordinates/builtin_frames/fk4.py
astropy/coordinates/builtin_frames/fk4_fk5_transforms.py
astropy/coordinates/builtin_frames/fk5.py
astropy/coordinates/builtin_frames/galactic.py
astropy/coordinates/builtin_frames/galactic_transforms.py
astropy/coordinates/builtin_frames/galactocentric.py
astropy/coordinates/builtin_frames/gcrs.py
astropy/coordinates/builtin_frames/hcrs.py
astropy/coordinates/builtin_frames/icrs.py
astropy/coordinates/builtin_frames/icrs_cirs_transforms.py
astropy/coordinates/builtin_frames/icrs_fk5_transforms.py
astropy/coordinates/builtin_frames/intermediate_rotation_transforms.py
astropy/coordinates/builtin_frames/itrs.py
astropy/coordinates/builtin_frames/lsr.py
astropy/coordinates/builtin_frames/skyoffset.py
astropy/coordinates/builtin_frames/supergalactic.py
astropy/coordinates/builtin_frames/supergalactic_transforms.py
astropy/coordinates/builtin_frames/utils.py
astropy/coordinates/calculation.py
astropy/coordinates/data/constellation_data_roman87.dat
astropy/coordinates/data/constellation_names.dat
astropy/coordinates/data/sites.json
astropy/coordinates/distances.py
astropy/coordinates/earth.py
astropy/coordinates/earth_orientation.py
astropy/coordinates/errors.py
astropy/coordinates/funcs.py
astropy/coordinates/jparser.py
astropy/coordinates/matching.py
astropy/coordinates/matrix_utilities.py
astropy/coordinates/name_resolve.py
astropy/coordinates/orbital_elements.py
astropy/coordinates/representation.py
astropy/coordinates/sites.py
astropy/coordinates/sky_coordinate.py
astropy/coordinates/sky_coordinate_parsers.py
astropy/coordinates/solar_system.py
astropy/coordinates/tests/__init__.py
astropy/coordinates/tests/accuracy/__init__.py
astropy/coordinates/tests/accuracy/data/fk4_no_e_fk4.csv
astropy/coordinates/tests/accuracy/data/fk4_no_e_fk5.csv
astropy/coordinates/tests/accuracy/data/galactic_fk4.csv
astropy/coordinates/tests/accuracy/data/icrs_fk5.csv
astropy/coordinates/tests/accuracy/generate_ref_ast.py
astropy/coordinates/tests/accuracy/test_altaz_icrs.py
astropy/coordinates/tests/accuracy/test_ecliptic.py
astropy/coordinates/tests/accuracy/test_fk4_no_e_fk4.py
astropy/coordinates/tests/accuracy/test_fk4_no_e_fk5.py
astropy/coordinates/tests/accuracy/test_galactic_fk4.py
astropy/coordinates/tests/accuracy/test_icrs_fk5.py
astropy/coordinates/tests/conftest.py
astropy/coordinates/tests/test_angles.py
astropy/coordinates/tests/test_angular_separation.py
astropy/coordinates/tests/test_api_ape5.py
astropy/coordinates/tests/test_arrays.py
astropy/coordinates/tests/test_atc_replacements.py
astropy/coordinates/tests/test_celestial_transformations.py
astropy/coordinates/tests/test_distance.py
astropy/coordinates/tests/test_earth.py
astropy/coordinates/tests/test_finite_difference_velocities.py
astropy/coordinates/tests/test_formatting.py
astropy/coordinates/tests/test_frames.py
astropy/coordinates/tests/test_frames_with_velocity.py
astropy/coordinates/tests/test_funcs.py
astropy/coordinates/tests/test_iau_fullstack.py
astropy/coordinates/tests/test_intermediate_transformations.py
astropy/coordinates/tests/test_matching.py
astropy/coordinates/tests/test_matrix_utilities.py
astropy/coordinates/tests/test_name_resolve.py
astropy/coordinates/tests/test_pickle.py
astropy/coordinates/tests/test_regression.py
astropy/coordinates/tests/test_representation.py
astropy/coordinates/tests/test_representation_arithmetic.py
astropy/coordinates/tests/test_representation_methods.py
astropy/coordinates/tests/test_shape_manipulation.py
astropy/coordinates/tests/test_sites.py
astropy/coordinates/tests/test_sky_coord.py
astropy/coordinates/tests/test_sky_coord_velocities.py
astropy/coordinates/tests/test_skyoffset_transformations.py
astropy/coordinates/tests/test_solar_system.py
astropy/coordinates/tests/test_transformations.py
astropy/coordinates/tests/test_unit_representation.py
astropy/coordinates/tests/test_velocity_corrs.py
astropy/coordinates/tests/utils.py
astropy/coordinates/transformations.py
astropy/cosmology/__init__.py
astropy/cosmology/core.py
astropy/cosmology/funcs.py
astropy/cosmology/parameters.py
astropy/cosmology/scalar_inv_efuncs.pyx
astropy/cosmology/tests/__init__.py
astropy/cosmology/tests/test_cosmology.py
astropy/cosmology/tests/test_pickle.py
astropy/extern/README.rst
astropy/extern/__init__.py
astropy/extern/_strptime.py
astropy/extern/bundled/__init__.py
astropy/extern/bundled/six.py
astropy/extern/configobj/__init__.py
astropy/extern/configobj/configobj.py
astropy/extern/configobj/validate.py
astropy/extern/jquery/__init__.py
astropy/extern/jquery/data/css/jquery.dataTables.css
astropy/extern/jquery/data/js/jquery-3.1.1.js
astropy/extern/jquery/data/js/jquery-3.1.1.min.js
astropy/extern/jquery/data/js/jquery.dataTables.js
astropy/extern/jquery/data/js/jquery.dataTables.min.js
astropy/extern/ply/__init__.py
astropy/extern/ply/cpp.py
astropy/extern/ply/ctokens.py
astropy/extern/ply/lex.py
astropy/extern/ply/yacc.py
astropy/extern/ply/ygen.py
astropy/extern/six.py
astropy/io/__init__.py
astropy/io/ascii/__init__.py
astropy/io/ascii/basic.py
astropy/io/ascii/cds.py
astropy/io/ascii/connect.py
astropy/io/ascii/core.py
astropy/io/ascii/cparser.pyx
astropy/io/ascii/daophot.py
astropy/io/ascii/docs.py
astropy/io/ascii/ecsv.py
astropy/io/ascii/fastbasic.py
astropy/io/ascii/fixedwidth.py
astropy/io/ascii/html.py
astropy/io/ascii/ipac.py
astropy/io/ascii/latex.py
astropy/io/ascii/misc.py
astropy/io/ascii/rst.py
astropy/io/ascii/setup_package.py
astropy/io/ascii/sextractor.py
astropy/io/ascii/src/tokenizer.c
astropy/io/ascii/src/tokenizer.h
astropy/io/ascii/tests/__init__.py
astropy/io/ascii/tests/common.py
astropy/io/ascii/tests/data/apostrophe.rdb
astropy/io/ascii/tests/data/apostrophe.tab
astropy/io/ascii/tests/data/bad.txt
astropy/io/ascii/tests/data/bars_at_ends.txt
astropy/io/ascii/tests/data/cds.dat
astropy/io/ascii/tests/data/cds/description/ReadMe
astropy/io/ascii/tests/data/cds/description/table.dat
astropy/io/ascii/tests/data/cds/glob/ReadMe
astropy/io/ascii/tests/data/cds/glob/lmxbrefs.dat
astropy/io/ascii/tests/data/cds/multi/ReadMe
astropy/io/ascii/tests/data/cds/multi/lhs2065.dat
astropy/io/ascii/tests/data/cds/multi/lp944-20.dat
astropy/io/ascii/tests/data/cds2.dat
astropy/io/ascii/tests/data/cds_malformed.dat
astropy/io/ascii/tests/data/commented_header.dat
astropy/io/ascii/tests/data/commented_header2.dat
astropy/io/ascii/tests/data/continuation.dat
astropy/io/ascii/tests/data/daophot.dat
astropy/io/ascii/tests/data/daophot.dat.gz
astropy/io/ascii/tests/data/daophot2.dat
astropy/io/ascii/tests/data/daophot3.dat
astropy/io/ascii/tests/data/daophot4.dat
astropy/io/ascii/tests/data/fill_values.txt
astropy/io/ascii/tests/data/fixed_width_2_line.txt
astropy/io/ascii/tests/data/html.html
astropy/io/ascii/tests/data/html2.html
astropy/io/ascii/tests/data/ipac.dat
astropy/io/ascii/tests/data/ipac.dat.bz2
astropy/io/ascii/tests/data/ipac.dat.xz
astropy/io/ascii/tests/data/latex1.tex
astropy/io/ascii/tests/data/latex1.tex.gz
astropy/io/ascii/tests/data/latex2.tex
astropy/io/ascii/tests/data/latex3.tex
astropy/io/ascii/tests/data/nls1_stackinfo.dbout
astropy/io/ascii/tests/data/no_data_cds.dat
astropy/io/ascii/tests/data/no_data_daophot.dat
astropy/io/ascii/tests/data/no_data_ipac.dat
astropy/io/ascii/tests/data/no_data_sextractor.dat
astropy/io/ascii/tests/data/no_data_with_header.dat
astropy/io/ascii/tests/data/no_data_without_header.dat
astropy/io/ascii/tests/data/sextractor.dat
astropy/io/ascii/tests/data/sextractor2.dat
astropy/io/ascii/tests/data/sextractor3.dat
astropy/io/ascii/tests/data/short.rdb
astropy/io/ascii/tests/data/short.rdb.bz2
astropy/io/ascii/tests/data/short.rdb.gz
astropy/io/ascii/tests/data/short.rdb.xz
astropy/io/ascii/tests/data/short.tab
astropy/io/ascii/tests/data/simple.txt
astropy/io/ascii/tests/data/simple2.txt
astropy/io/ascii/tests/data/simple3.txt
astropy/io/ascii/tests/data/simple4.txt
astropy/io/ascii/tests/data/simple5.txt
astropy/io/ascii/tests/data/simple_csv.csv
astropy/io/ascii/tests/data/simple_csv_missing.csv
astropy/io/ascii/tests/data/space_delim_blank_lines.txt
astropy/io/ascii/tests/data/space_delim_no_header.dat
astropy/io/ascii/tests/data/space_delim_no_names.dat
astropy/io/ascii/tests/data/test4.dat
astropy/io/ascii/tests/data/test5.dat
astropy/io/ascii/tests/data/vizier/ReadMe
astropy/io/ascii/tests/data/vizier/table1.dat
astropy/io/ascii/tests/data/vizier/table5.dat
astropy/io/ascii/tests/data/vots_spec.dat
astropy/io/ascii/tests/data/whitespace.dat
astropy/io/ascii/tests/test_c_reader.py
astropy/io/ascii/tests/test_cds_header_from_readme.py
astropy/io/ascii/tests/test_compressed.py
astropy/io/ascii/tests/test_connect.py
astropy/io/ascii/tests/test_ecsv.py
astropy/io/ascii/tests/test_fixedwidth.py
astropy/io/ascii/tests/test_html.py
astropy/io/ascii/tests/test_ipac_definitions.py
astropy/io/ascii/tests/test_read.py
astropy/io/ascii/tests/test_rst.py
astropy/io/ascii/tests/test_types.py
astropy/io/ascii/tests/test_write.py
astropy/io/ascii/ui.py
astropy/io/fits/__init__.py
astropy/io/fits/_utils.pyx
astropy/io/fits/card.py
astropy/io/fits/column.py
astropy/io/fits/connect.py
astropy/io/fits/convenience.py
astropy/io/fits/diff.py
astropy/io/fits/file.py
astropy/io/fits/fitsrec.py
astropy/io/fits/fitstime.py
astropy/io/fits/hdu/__init__.py
astropy/io/fits/hdu/base.py
astropy/io/fits/hdu/compressed.py
astropy/io/fits/hdu/groups.py
astropy/io/fits/hdu/hdulist.py
astropy/io/fits/hdu/image.py
astropy/io/fits/hdu/nonstandard.py
astropy/io/fits/hdu/streaming.py
astropy/io/fits/hdu/table.py
astropy/io/fits/header.py
astropy/io/fits/scripts/__init__.py
astropy/io/fits/scripts/fitscheck.py
astropy/io/fits/scripts/fitsdiff.py
astropy/io/fits/scripts/fitsheader.py
astropy/io/fits/scripts/fitsinfo.py
astropy/io/fits/setup_package.py
astropy/io/fits/src/compressionmodule.c
astropy/io/fits/src/compressionmodule.h
astropy/io/fits/tests/__init__.py
astropy/io/fits/tests/cfitsio_verify.c
astropy/io/fits/tests/data/arange.fits
astropy/io/fits/tests/data/ascii.fits
astropy/io/fits/tests/data/blank.fits
astropy/io/fits/tests/data/btable.fits
astropy/io/fits/tests/data/chandra_time.fits
astropy/io/fits/tests/data/checksum.fits
astropy/io/fits/tests/data/comp.fits
astropy/io/fits/tests/data/compressed_float_bzero.fits
astropy/io/fits/tests/data/compressed_image.fits
astropy/io/fits/tests/data/fixed-1890.fits
astropy/io/fits/tests/data/group.fits
astropy/io/fits/tests/data/history_header.fits
astropy/io/fits/tests/data/memtest.fits
astropy/io/fits/tests/data/o4sp040b0_raw.fits
astropy/io/fits/tests/data/random_groups.fits
astropy/io/fits/tests/data/scale.fits
astropy/io/fits/tests/data/stddata.fits
astropy/io/fits/tests/data/table.fits
astropy/io/fits/tests/data/tb.fits
astropy/io/fits/tests/data/tdim.fits
astropy/io/fits/tests/data/test0.fits
astropy/io/fits/tests/data/test1.fits
astropy/io/fits/tests/data/variable_length_table.fits
astropy/io/fits/tests/data/zerowidth.fits
astropy/io/fits/tests/test_checksum.py
astropy/io/fits/tests/test_compression_failures.py
astropy/io/fits/tests/test_connect.py
astropy/io/fits/tests/test_convenience.py
astropy/io/fits/tests/test_core.py
astropy/io/fits/tests/test_diff.py
astropy/io/fits/tests/test_division.py
astropy/io/fits/tests/test_fitscheck.py
astropy/io/fits/tests/test_fitsdiff.py
astropy/io/fits/tests/test_fitsheader.py
astropy/io/fits/tests/test_fitsinfo.py
astropy/io/fits/tests/test_fitstime.py
astropy/io/fits/tests/test_groups.py
astropy/io/fits/tests/test_hdulist.py
astropy/io/fits/tests/test_header.py
astropy/io/fits/tests/test_image.py
astropy/io/fits/tests/test_nonstandard.py
astropy/io/fits/tests/test_structured.py
astropy/io/fits/tests/test_table.py
astropy/io/fits/tests/test_uint.py
astropy/io/fits/tests/test_util.py
astropy/io/fits/util.py
astropy/io/fits/verify.py
astropy/io/misc/__init__.py
astropy/io/misc/asdf/__init__.py
astropy/io/misc/asdf/connect.py
astropy/io/misc/asdf/data/schemas/astropy.org/astropy/coordinates/angle-1.0.0.yaml
astropy/io/misc/asdf/data/schemas/astropy.org/astropy/coordinates/earthlocation-1.0.0.yaml
astropy/io/misc/asdf/data/schemas/astropy.org/astropy/coordinates/frames/baseframe-1.0.0.yaml
astropy/io/misc/asdf/data/schemas/astropy.org/astropy/coordinates/frames/cirs-1.0.0.yaml
astropy/io/misc/asdf/data/schemas/astropy.org/astropy/coordinates/frames/fk4-1.0.0.yaml
astropy/io/misc/asdf/data/schemas/astropy.org/astropy/coordinates/frames/fk4noeterms-1.0.0.yaml
astropy/io/misc/asdf/data/schemas/astropy.org/astropy/coordinates/frames/fk5-1.0.0.yaml
astropy/io/misc/asdf/data/schemas/astropy.org/astropy/coordinates/frames/galactic-1.0.0.yaml
astropy/io/misc/asdf/data/schemas/astropy.org/astropy/coordinates/frames/galactocentric-1.0.0.yaml
astropy/io/misc/asdf/data/schemas/astropy.org/astropy/coordinates/frames/gcrs-1.0.0.yaml
astropy/io/misc/asdf/data/schemas/astropy.org/astropy/coordinates/frames/icrs-1.0.0.yaml
astropy/io/misc/asdf/data/schemas/astropy.org/astropy/coordinates/frames/icrs-1.1.0.yaml
astropy/io/misc/asdf/data/schemas/astropy.org/astropy/coordinates/frames/itrs-1.0.0.yaml
astropy/io/misc/asdf/data/schemas/astropy.org/astropy/coordinates/frames/precessedgeocentric-1.0.0.yaml
astropy/io/misc/asdf/data/schemas/astropy.org/astropy/coordinates/latitude-1.0.0.yaml
astropy/io/misc/asdf/data/schemas/astropy.org/astropy/coordinates/longitude-1.0.0.yaml
astropy/io/misc/asdf/data/schemas/astropy.org/astropy/coordinates/representation-1.0.0.yaml
astropy/io/misc/asdf/data/schemas/astropy.org/astropy/coordinates/skycoord-1.0.0.yaml
astropy/io/misc/asdf/data/schemas/astropy.org/astropy/fits/fits-1.0.0.yaml
astropy/io/misc/asdf/data/schemas/astropy.org/astropy/table/table-1.0.0.yaml
astropy/io/misc/asdf/data/schemas/astropy.org/astropy/time/timedelta-1.0.0.yaml
astropy/io/misc/asdf/data/schemas/astropy.org/astropy/units/equivalency-1.0.0.yaml
astropy/io/misc/asdf/extension.py
astropy/io/misc/asdf/tags/__init__.py
astropy/io/misc/asdf/tags/coordinates/__init__.py
astropy/io/misc/asdf/tags/coordinates/angle.py
astropy/io/misc/asdf/tags/coordinates/earthlocation.py
astropy/io/misc/asdf/tags/coordinates/frames.py
astropy/io/misc/asdf/tags/coordinates/representation.py
astropy/io/misc/asdf/tags/coordinates/skycoord.py
astropy/io/misc/asdf/tags/coordinates/tests/__init__.py
astropy/io/misc/asdf/tags/coordinates/tests/test_angle.py
astropy/io/misc/asdf/tags/coordinates/tests/test_earthlocation.py
astropy/io/misc/asdf/tags/coordinates/tests/test_frames.py
astropy/io/misc/asdf/tags/coordinates/tests/test_representation.py
astropy/io/misc/asdf/tags/coordinates/tests/test_skycoord.py
astropy/io/misc/asdf/tags/fits/__init__.py
astropy/io/misc/asdf/tags/fits/fits.py
astropy/io/misc/asdf/tags/fits/tests/__init__.py
astropy/io/misc/asdf/tags/fits/tests/data/complex.fits
astropy/io/misc/asdf/tags/fits/tests/test_fits.py
astropy/io/misc/asdf/tags/table/__init__.py
astropy/io/misc/asdf/tags/table/table.py
astropy/io/misc/asdf/tags/table/tests/__init__.py
astropy/io/misc/asdf/tags/table/tests/test_table.py
astropy/io/misc/asdf/tags/tests/__init__.py
astropy/io/misc/asdf/tags/tests/helpers.py
astropy/io/misc/asdf/tags/time/__init__.py
astropy/io/misc/asdf/tags/time/tests/__init__.py
astropy/io/misc/asdf/tags/time/tests/test_time.py
astropy/io/misc/asdf/tags/time/tests/test_timedelta.py
astropy/io/misc/asdf/tags/time/time.py
astropy/io/misc/asdf/tags/time/timedelta.py
astropy/io/misc/asdf/tags/transform/__init__.py
astropy/io/misc/asdf/tags/transform/basic.py
astropy/io/misc/asdf/tags/transform/compound.py
astropy/io/misc/asdf/tags/transform/polynomial.py
astropy/io/misc/asdf/tags/transform/projections.py
astropy/io/misc/asdf/tags/transform/tabular.py
astropy/io/misc/asdf/tags/transform/tests/__init__.py
astropy/io/misc/asdf/tags/transform/tests/test_transform.py
astropy/io/misc/asdf/tags/unit/__init__.py
astropy/io/misc/asdf/tags/unit/equivalency.py
astropy/io/misc/asdf/tags/unit/quantity.py
astropy/io/misc/asdf/tags/unit/tests/__init__.py
astropy/io/misc/asdf/tags/unit/tests/test_equivalency.py
astropy/io/misc/asdf/tags/unit/tests/test_quantity.py
astropy/io/misc/asdf/tags/unit/tests/test_unit.py
astropy/io/misc/asdf/tags/unit/unit.py
astropy/io/misc/asdf/tests/__init__.py
astropy/io/misc/asdf/tests/test_io.py
astropy/io/misc/asdf/types.py
astropy/io/misc/connect.py
astropy/io/misc/hdf5.py
astropy/io/misc/pandas/__init__.py
astropy/io/misc/pandas/connect.py
astropy/io/misc/pickle_helpers.py
astropy/io/misc/tests/__init__.py
astropy/io/misc/tests/test_hdf5.py
astropy/io/misc/tests/test_pandas.py
astropy/io/misc/tests/test_pickle_helpers.py
astropy/io/misc/tests/test_yaml.py
astropy/io/misc/yaml.py
astropy/io/registry.py
astropy/io/tests/__init__.py
astropy/io/tests/test_registry.py
astropy/io/tests/test_registry_help.py
astropy/io/votable/__init__.py
astropy/io/votable/connect.py
astropy/io/votable/converters.py
astropy/io/votable/data/VOTable.dtd
astropy/io/votable/data/VOTable.v1.1.xsd
astropy/io/votable/data/VOTable.v1.2.xsd
astropy/io/votable/data/VOTable.v1.3.xsd
astropy/io/votable/data/ucd1p-words.txt
astropy/io/votable/exceptions.py
astropy/io/votable/setup_package.py
astropy/io/votable/src/.gitignore
astropy/io/votable/src/tablewriter.c
astropy/io/votable/table.py
astropy/io/votable/tests/__init__.py
astropy/io/votable/tests/converter_test.py
astropy/io/votable/tests/data/custom_datatype.xml
astropy/io/votable/tests/data/empty_table.xml
astropy/io/votable/tests/data/gemini.xml
astropy/io/votable/tests/data/irsa-nph-error.xml
astropy/io/votable/tests/data/irsa-nph-m31.xml
astropy/io/votable/tests/data/names.xml
astropy/io/votable/tests/data/no_resource.txt
astropy/io/votable/tests/data/no_resource.xml
astropy/io/votable/tests/data/nonstandard_units.xml
astropy/io/votable/tests/data/regression.bin.tabledata.truth.1.1.xml
astropy/io/votable/tests/data/regression.bin.tabledata.truth.1.3.xml
astropy/io/votable/tests/data/regression.xml
astropy/io/votable/tests/data/resource_groups.xml
astropy/io/votable/tests/data/tb.fits
astropy/io/votable/tests/data/too_many_columns.xml.gz
astropy/io/votable/tests/data/validation.txt
astropy/io/votable/tests/exception_test.py
astropy/io/votable/tests/resource_test.py
astropy/io/votable/tests/table_test.py
astropy/io/votable/tests/tree_test.py
astropy/io/votable/tests/ucd_test.py
astropy/io/votable/tests/util_test.py
astropy/io/votable/tests/vo_test.py
astropy/io/votable/tree.py
astropy/io/votable/ucd.py
astropy/io/votable/util.py
astropy/io/votable/validator/__init__.py
astropy/io/votable/validator/data/urls/cone.big.dat.gz
astropy/io/votable/validator/data/urls/cone.broken.dat.gz
astropy/io/votable/validator/data/urls/cone.good.dat.gz
astropy/io/votable/validator/data/urls/cone.incorrect.dat.gz
astropy/io/votable/validator/html.py
astropy/io/votable/validator/main.py
astropy/io/votable/validator/result.py
astropy/io/votable/volint.py
astropy/io/votable/xmlutil.py
astropy/logger.py
astropy/modeling/__init__.py
astropy/modeling/blackbody.py
astropy/modeling/core.py
astropy/modeling/fitting.py
astropy/modeling/functional_models.py
astropy/modeling/mappings.py
astropy/modeling/models.py
astropy/modeling/optimizers.py
astropy/modeling/parameters.py
astropy/modeling/polynomial.py
astropy/modeling/powerlaws.py
astropy/modeling/projections.py
astropy/modeling/rotations.py
astropy/modeling/separable.py
astropy/modeling/setup_package.py
astropy/modeling/src/.gitignore
astropy/modeling/src/projections.c.templ
astropy/modeling/statistic.py
astropy/modeling/tabular.py
astropy/modeling/tests/__init__.py
astropy/modeling/tests/data/1904-66_AZP.fits
astropy/modeling/tests/data/__init__.py
astropy/modeling/tests/data/hst_sip.hdr
astropy/modeling/tests/data/idcompspec.fits
astropy/modeling/tests/data/irac_sip.hdr
astropy/modeling/tests/example_models.py
astropy/modeling/tests/irafutil.py
astropy/modeling/tests/test_blackbody.py
astropy/modeling/tests/test_compound.py
astropy/modeling/tests/test_constraints.py
astropy/modeling/tests/test_core.py
astropy/modeling/tests/test_fitters.py
astropy/modeling/tests/test_functional_models.py
astropy/modeling/tests/test_input.py
astropy/modeling/tests/test_mappings.py
astropy/modeling/tests/test_model_sets.py
astropy/modeling/tests/test_models.py
astropy/modeling/tests/test_models_quantities.py
astropy/modeling/tests/test_parameters.py
astropy/modeling/tests/test_polynomial.py
astropy/modeling/tests/test_projections.py
astropy/modeling/tests/test_quantities_evaluation.py
astropy/modeling/tests/test_quantities_fitting.py
astropy/modeling/tests/test_quantities_model.py
astropy/modeling/tests/test_quantities_parameters.py
astropy/modeling/tests/test_quantities_rotations.py
astropy/modeling/tests/test_rotations.py
astropy/modeling/tests/test_separable.py
astropy/modeling/tests/test_utils.py
astropy/modeling/tests/utils.py
astropy/modeling/utils.py
astropy/nddata/__init__.py
astropy/nddata/bitmask.py
astropy/nddata/ccddata.py
astropy/nddata/compat.py
astropy/nddata/decorators.py
astropy/nddata/flag_collection.py
astropy/nddata/mixins/__init__.py
astropy/nddata/mixins/ndarithmetic.py
astropy/nddata/mixins/ndio.py
astropy/nddata/mixins/ndslicing.py
astropy/nddata/mixins/tests/__init__.py
astropy/nddata/mixins/tests/test_ndarithmetic.py
astropy/nddata/mixins/tests/test_ndio.py
astropy/nddata/mixins/tests/test_ndslicing.py
astropy/nddata/nddata.py
astropy/nddata/nddata_base.py
astropy/nddata/nddata_withmixins.py
astropy/nddata/nduncertainty.py
astropy/nddata/tests/__init__.py
astropy/nddata/tests/data/sip-wcs.fits
astropy/nddata/tests/test_bitmask.py
astropy/nddata/tests/test_ccddata.py
astropy/nddata/tests/test_compat.py
astropy/nddata/tests/test_decorators.py
```


# The last commit

```
7b678175a SWE-bench


```

```diff

```


# CONTRIBUTING.md (the start)

```
Contributing to Astropy
=======================

Reporting Issues
----------------

When opening an issue to report a problem, please try to provide a minimal code
example that reproduces the issue along with details of the operating
system and the Python, NumPy, and `astropy` versions you are using.

Contributing Code
-----------------

So you are interested in contributing code to the Astropy Project? Excellent!
We love contributions! Astropy is open source, built on open source,
and we'd love to have you hang out in our community.

**Imposter syndrome disclaimer**: We want your help. No, really.

There may be a little voice inside your head that is telling you that you're not
ready to be an open source contributor; that your skills aren't nearly good
enough to contribute. What could you possibly offer a project like this one?

We assure you - the little voice in your head is wrong. If you can write code at
all, you can contribute code to open source. Contributing to open source
projects is a fantastic way to advance one's coding skills. Writing perfect code
isn't the measure of a good developer (that would disqualify all of us!); it's
trying to create something, making mistakes, and learning from those
mistakes. That's how we all improve, and we are happy to help others learn.

Being an open source contributor doesn't just mean writing code, either. You can
help out by writing documentation, tests, or even giving feedback about the
project (and yes - that includes giving feedback about the contribution
process). Some of these contributions may be the most valuable to the project as
a whole, because you're coming to the project with fresh eyes, so you can see
the errors and assumptions that seasoned contributors have glossed over.

Note: This disclaimer was originally written by
`Adrienne Lowe <https://github.com/adriennefriend>`_ for a
`PyCon talk <https://www.youtube.com/watch?v=6Uj746j9Heo>`_, and was adapted by
Astropy based on its use in the README file for the
`MetPy project <https://github.com/Unidata/MetPy>`_.

Most contributions to Astropy are done via pull requests from GitHub users'
forks of the [astropy repository](https://github.com/astropy/astropy). If you
are new to this style of development, you will want to read over our
[development workflow](http://docs.astropy.org/en/latest/development/workflow/development_workflow.html).

You may also/instead be interested in contributing to an
[astropy affiliated package](http://www.astropy.org/affiliated/).
Affiliated packages are astronomy-related software packages that are not a part
of the `astropy` core package, but build on it for more specialized applications
and follow the Astropy guidelines for reuse, interoperability, and interfacing.
Each affiliated package has its own developers/maintainers and its own specific
guidelines for contributions, so be sure to read their docs.

Once you open a pull request (which should be opened against the ``master``
branch, not against any of the other branches), please make sure to
include the following:

- **Code**: the code you are adding, which should follow
  our [coding guidelines](http://docs.astropy.org/en/latest/development/codeguide.html) as much as possible.

- **Tests**: these are usually tests to ensure code that previously
  failed now works (regression tests), or tests that cover as much as possible
  of the new functionality to make sure it does not break in the future and
  also returns consistent results on all platforms (since we run these tests on
  many platforms/configurations). For more information about how to write
  tests, see our [testing guidelines](http://docs.astropy.org/en/latest/development/testguide.html).

- **Documentation**: if you are adding new functionality, be sure to include a
  description in the main documentation (in ``docs/``). Again, we have some
  detailed [documentation guidelines](http://docs.astropy.org/en/latest/development/docguide.html) to help you out.

- **Performance improvements**: if you are making changes that impact `astropy`
  performance, consider adding a performance benchmark in the
  [astropy-benchmarks](https://github.com/astropy/astropy-benchmarks)
  repository. You can find out more about how to do this
  [in the README for that repository](https://github.com/astropy/astropy-benchmarks#contributing-a-benchmark).

- **Changelog entry**: whether you are fixing a bug or adding new
  functionality, you should add an entry to the ``CHANGES.rst`` file that
  includes the PR number. If you are opening a pull request you may not know
  the PR number yet, but you can add it once the pull request is open. If you
  are not sure where to put the changelog entry, wait until a maintainer
  has reviewed your PR and assigned it to a milestone.

  You do not need to include a changelog entry for fixes to bugs introduced in
  the developer version and therefore are not present in the stable releases. In
  general you do not need to include a changelog entry for minor documentation
  or test updates. Only user-visible changes (new features/API changes, fixed
  issues) need to be mentioned. If in doubt, ask the core maintainer reviewing
  your changes.

Other Tips
----------

- To prevent the automated tests from running, you can add ``[ci skip]`` to your
  commit message. This is useful if your PR is a work in progress and you are
  not yet ready for the tests to run. For example:

      $ git commit -m "WIP widget [ci skip]"

  - If you already made the commit without including this string, you can edit
    your existing commit message by running:

        $ git commit --amend

- To skip only the AppVeyor (Windows) CI builds you can use ``[skip appveyor]``,
  and to skip testing on Travis CI use ``[skip travis]``.

- If your commit makes substantial changes to the documentation but no code
  changes, then you can use ``[docs only]``, which will skip all but the
  documentation building jobs on Travis.

- When contributing trivial documenta
```
````

### `plan.md`

```
## Deliverable
changes to this tree

## Check
`python -m pytest astropy/io/fits/tests/test_header.py`

## Scope
`astropy/io/fits/header.py`
`astropy/io/fits/card.py`
`astropy/io/fits/tests/`

## Done when
`Header.fromstring` accepts a Python 3 `bytes` argument and produces the same header as the equivalent `str`.
`Header.fromstring` continues to accept unicode `str` input.
`Card.fromstring` accepts a Python 3 `bytes` argument and produces the same card as the equivalent `str`.
`Card.fromstring` continues to accept unicode `str` input.
Existing `Header` and `Card` string-input behavior is unchanged.

## Approach
Normalize `bytes` at the public entry points, then reuse the existing string parsing path. Decompose into: inspect `Header.fromstring` and `Card.fromstring`; decide where bytes-to-text conversion belongs; ensure `Header.fromstring` handles whole-header input before card splitting; ensure direct `Card.fromstring` calls handle bytes; run the focused fits header tests.

Candidate 1: decode bytes immediately inside `Header.fromstring` and `Card.fromstring` using the FITS-appropriate ASCII decoding, leaving all later parsing unchanged. Tradeoff: smallest, clearest change and preserves existing error paths for non-ASCII or malformed cards.

Candidate 2: add a shared private helper for “accept str or bytes, return str” and call it from both methods. Tradeoff: avoids duplicated decoding logic and can enforce consistent error messages, but touches more code and may affect other internal callers if adopted broadly.

Candidate 3: change `Header.fromstring` only and rely on it to pass decoded strings into `Card.fromstring`. Tradeoff: fixes the reported `Header` path but leaves direct `Card.fromstring` calls broken, so it does not satisfy the prompt’s likely `Card` requirement.

If the first attempt fails, check whether the failure is from decoding too late, after newline/card splitting, or from using an encoding that does not round-trip the FITS header bytes. Prefer decoding once at the method boundary and keeping the existing text-based logic intact.
```

### `prompt.md`

```
Header.fromstring does not accept Python 3 bytes
According to [the docs](http://docs.astropy.org/en/stable/_modules/astropy/io/fits/header.html#Header.fromstring), the method `Header.fromstring` "...creates an HDU header from a byte string containing the entire header data."

By "byte string" here it really means the `str` type which on Python 2 could be raw binary data, but on Python 3 explicitly is not.   In fact it does work on Python 3's unicode `str`s, but here it assumes that the data can be ASCII-encoded.

Its counterpart, `Header.fromfile` will work with files opened in text or binary mode.  So probably the simplest solution for now (as opposed to adding new methods or something like that) is to change `Header.fromstring` to accept unicode or bytes string types.

`Card.fromstring` likely needs a similar treatment.
```

### `review.md`

```
verdict: PASS

- The change implements the core requirement: `Card.fromstring` decodes `bytes` via `decode_ascii` before `_pad`, and `Header.fromstring` decodes both `data` and `sep` when they are `bytes`; `str` input is untouched, so existing behavior is preserved.
- `decode_ascii` is already available in `astropy/io/fits/util.py` (imported in `card.py` and used as a bare name in `header.py`, where it was already in scope); the new tests exercise both `bytes` and `str` paths and the suite reaches 150 passing tests, so the import resolves.
- `Header.fromstring(hstr, sep=b'\n')` and the equivalent with `sep='\n'` are both covered by `test_header_from_bytes`; `Card.fromstring(b'ABC     = F')` is covered by `test_card_from_bytes`. This satisfies every "Done when" item.
- The two failing tests (`test_fitsheader_script`, `test_fitsheader_table_feature`) are unrelated: they fail inside `astropy.table._np_utils` on `np.int` removed in NumPy 1.25, and the baseline tree fails them too. They are environment drift, not regressions from this change.
- Note (not a failure): `CHANGES.rst` is listed as OUTSIDE THE SCOPE. It is a changelog entry only; the task neither asked for it nor needs it, and per the review rules a changelog entry is a note rather than a reason to fail. No outcome depends on it. If strict scope cleanliness is wanted, it can be reverted, but nothing in the fix is affected.
```

### `scope.txt`

```
scope: astropy/io/fits/header.py astropy/io/fits/card.py astropy/io/fits/tests
OUTSIDE THE SCOPE: CHANGES.rst +3 -0 (undo it: git checkout the file, or delete it when the run made it)
changed: astropy/io/fits/card.py +7 -5
changed: astropy/io/fits/header.py +9 -3
changed: astropy/io/fits/tests/test_header.py +26 -0
```

### `task.md`

```
# Task

## Prompt

Header.fromstring does not accept Python 3 bytes
According to [the docs](http://docs.astropy.org/en/stable/_modules/astropy/io/fits/header.html#Header.fromstring), the method `Header.fromstring` "...creates an HDU header from a byte string containing the entire header data."

By "byte string" here it really means the `str` type which on Python 2 could be raw binary data, but on Python 3 explicitly is not.   In fact it does work on Python 3's unicode `str`s, but here it assumes that the data can be ASCII-encoded.

Its counterpart, `Header.fromfile` will work with files opened in text or binary mode.  So probably the simplest solution for now (as opposed to adding new methods or something like that) is to change `Header.fromstring` to accept unicode or bytes string types.

`Card.fromstring` likely needs a similar treatment.

## Deliverable

changes to this tree

## Check

`python -m pytest astropy/io/fits/tests/test_header.py`

## Scope

`astropy/io/fits/header.py`
`astropy/io/fits/card.py`
`astropy/io/fits/tests/`

## Done when

`Header.fromstring` accepts a Python 3 `bytes` argument and produces the same header as the equivalent `str`.
`Header.fromstring` continues to accept unicode `str` input.
`Card.fromstring` accepts a Python 3 `bytes` argument and produces the same card as the equivalent `str`.
`Card.fromstring` continues to accept unicode `str` input.
Existing `Header` and `Card` string-input behavior is unchanged.
```

### `test-output.log`

```
check: python -m pytest astropy/io/fits/tests/test_header.py
============================= test session starts ==============================
platform linux -- Python 3.9.20, pytest-7.1.2, pluggy-1.3.0
Matplotlib: 3.9.2
Freetype: 2.6.1

Running tests with Astropy version 4.0.dev24591.
Running tests in astropy/io/fits/tests/test_header.py.

Date: 2026-11-06T10:49:09

Platform: Linux-7.0.0-1014-gcp-x86_64-with-glibc2.35

Executable: /opt/miniconda3/envs/testbed/bin/python

Full Python Version: 
3.9.20 (main, Oct  3 2024, 07:27:41) 
[GCC 11.2.0]

encodings: sys: utf-8, locale: UTF-8, filesystem: utf-8
byteorder: little
float info: dig: 15, mant_dig: 15

Numpy: 1.25.2
Scipy: not available
Matplotlib: 3.9.2
h5py: not available
Pandas: not available
Cython: not available
Scikit-image: not available
astropy_helpers: 3.2rc1
Using Astropy options: remote_data: none.

rootdir: /testbed, configfile: setup.cfg
plugins: doctestplus-1.0.0, remotedata-0.4.0, xdist-3.3.1, mpl-0.17.0, cov-4.1.0, openfiles-0.5.0, arraydiff-0.5.0, hypothesis-6.82.6, astropy-header-0.2.2, mock-3.11.1, filter-subpackage-0.1.2, astropy-0.10.0
collected 152 items

astropy/io/fits/tests/test_header.py ................................... [ 23%]
........................................................................ [ 70%]
.......................................FF....                            [100%]

=================================== FAILURES ===================================
_____________ TestRecordValuedKeywordCards.test_fitsheader_script ______________

self = <[AttributeError("module 'numpy' has no attribute 'int'.\n`np.int` was a deprecated alias for the builtin `int`. To av... https://numpy.org/devdocs/release/1.20.0-notes.html#deprecations") raised in repr()] HDUList object at 0x7fad71333310>
func = <built-in method __getitem__ of HDUList object at 0x7fad71333310>
args = (1,), kwargs = {}

    def _try_while_unread_hdus(self, func, *args, **kwargs):
        """
        Attempt an operation that accesses an HDU by index/name
        that can fail if not all HDUs have been read yet.  Keep
        reading HDUs until the operation succeeds or there are no
        more HDUs to read.
        """
    
        while True:
            try:
>               return func(*args, **kwargs)
E               IndexError: list index out of range

astropy/io/fits/hdu/hdulist.py:1096: IndexError

During handling of the above exception, another exception occurred:

self = <astropy.io.fits.tests.test_header.TestRecordValuedKeywordCards object at 0x7fad714139a0>

    def test_fitsheader_script(self):
        """Tests the basic functionality of the `fitsheader` script."""
        from astropy.io.fits.scripts import fitsheader
    
        # Can an extension by specified by the EXTNAME keyword?
        hf = fitsheader.HeaderFormatter(self.data('zerowidth.fits'))
>       output = hf.parse(extensions=['AIPS FQ'])

astropy/io/fits/tests/test_header.py:2744: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
astropy/io/fits/scripts/fitsheader.py:146: in parse
    return self._parse_internal(hdukeys, keywords, compressed)
astropy/io/fits/scripts/fitsheader.py:154: in _parse_internal
    cards = self._get_cards(hdu, keywords, compressed)
astropy/io/fits/scripts/fitsheader.py:195: in _get_cards
    header = self._hdulist[hdukey].header
astropy/io/fits/hdu/hdulist.py:300: in __getitem__
    self._positive_index_of(key))
astropy/io/fits/hdu/hdulist.py:754: in _positive_index_of
    index = self.index_of(key)
astropy/io/fits/hdu/hdulist.py:724: in index_of
    for idx, hdu in enumerate(self):
astropy/io/fits/hdu/hdulist.py:247: in __iter__
    yield self[idx]
astropy/io/fits/hdu/hdulist.py:299: in __getitem__
    return self._try_while_unread_hdus(super().__getitem__,
astropy/io/fits/hdu/hdulist.py:1098: in _try_while_unread_hdus
    if self._read_next_hdu():
astropy/io/fits/hdu/hdulist.py:1139: in _read_next_hdu
    hdu = _BaseHDU.readfrom(fileobj, **kwargs)
astropy/io/fits/hdu/base.py:315: in readfrom
    hdu = cls._readfrom_internal(fileobj, checksum=checksum,
astropy/io/fits/hdu/base.py:444: in _readfrom_internal
    hdu = cls(data=DELAYED, header=header, **new_kwargs)
astropy/io/fits/hdu/table.py:843: in __init__
    from astropy.table import Table
astropy/table/__init__.py:41: in <module>
    from .column import Column, MaskedColumn, StringTruncateWarning, ColumnInfo
astropy/table/column.py:28: in <module>
    from .np_utils import fix_column_name
astropy/table/np_utils.py:16: in <module>
    from . import _np_utils
astropy/table/_np_utils.pyx:15: in init astropy.table._np_utils
    DTYPE = np.int
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

attr = 'int'

    def __getattr__(attr):
        # Warn for expired attributes, and return a dummy function
        # that always raises an exception.
        import warnings
        import math
        try:
            msg = __expired_functions__[attr]
        except KeyError:
            pass
        else:
            warnings.warn(msg, DeprecationWarning, stacklevel=2)
    
            def _expired(*args, **kwds):
                raise RuntimeError(msg)
    
            return _expired
    
        # Emit warnings for deprecated attributes
        try:
            val, msg = __deprecated_attrs__[attr]
        except KeyError:
            pass
        else:
            warnings.warn(msg, DeprecationWarning, stacklevel=2)
            return val
    
        if attr in __future_scalars__:
            # And future warnings for those that will change, but also give
            # the AttributeError
            warnings.warn(
                f"In the future `np.{attr}` will be defined as the "
                "corresponding NumPy scalar.", FutureWarning, stacklevel=2)
    
        if attr in __former_attrs__:
>           raise AttributeError(__former_attrs__[attr])
E           AttributeError: module 'numpy' has no attribute 'int'.
E           `np.int` was a deprecated alias for the builtin `int`. To avoid this error in existing code, use `int` by itself. Doing this will not modify any behavior and is safe. When replacing `np.int`, you may wish to use e.g. `np.int64` or `np.int32` to specify the precision. If you wish to review your current use, check the release note link for additional information.
E           The aliases was originally deprecated in NumPy 1.20; for more details and guidance see the original release note at:
E               https://numpy.org/devdocs/release/1.20.0-notes.html#deprecations

/opt/miniconda3/envs/testbed/lib/python3.9/site-packages/numpy/__init__.py:319: AttributeError
__________ TestRecordValuedKeywordCards.test_fitsheader_table_feature __________

self = <astropy.io.fits.tests.test_header.TestRecordValuedKeywordCards object at 0x7fad71413af0>

    def test_fitsheader_table_feature(self):
        """Tests the `--table` feature of the `fitsheader` script."""
        from astropy.io import fits
        from astropy.io.fits.scripts import fitsheader
        test_filename = self.data('zerowidth.fits')
        fitsobj = fits.open(test_filename)
        formatter = fitsheader.TableHeaderFormatter(test_filename)
    
        # Does the table contain the expected number of rows?
>       mytable = formatter.parse([0])

astropy/io/fits/tests/test_header.py:2787: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
astropy/io/fits/scripts/fitsheader.py:146: in parse
    return self._parse_internal(hdukeys, keywords, compressed)
astropy/io/fits/scripts/fitsheader.py:246: in _parse_internal
    from astropy import table
astropy/table/__init__.py:41: in <module>
    from .column import Column, MaskedColumn, StringTruncateWarning, ColumnInfo
astropy/table/column.py:28: in <module>
    from .np_utils import fix_column_name
astropy/table/np_utils.py:16: in <module>
    from . import _np_utils
astropy/table/_np_utils.pyx:15: in init astropy.table._np_utils
    DTYPE = np.int
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

attr = 'int'

    def __getattr__(attr):
        # Warn for expired attributes, and return a dummy function
        # that always raises an exception.
        import warnings
        import math
        try:
            msg = __expired_functions__[attr]
        except KeyError:
            pass
        else:
            warnings.warn(msg, DeprecationWarning, stacklevel=2)
    
            def _expired(*args, **kwds):
                raise RuntimeError(msg)
    
            return _expired
    
        # Emit warnings for deprecated attributes
        try:
            val, msg = __deprecated_attrs__[attr]
        except KeyError:
            pass
        else:
            warnings.warn(msg, DeprecationWarning, stacklevel=2)
            return val
    
        if attr in __future_scalars__:
            # And future warnings for those that will change, but also give
            # the AttributeError
            warnings.warn(
                f"In the future `np.{attr}` will be defined as the "
                "corresponding NumPy scalar.", FutureWarning, stacklevel=2)
    
        if attr in __former_attrs__:
>           raise AttributeError(__former_attrs__[attr])
E           AttributeError: module 'numpy' has no attribute 'int'.
E           `np.int` was a deprecated alias for the builtin `int`. To avoid this error in existing code, use `int` by itself. Doing this will not modify any behavior and is safe. When replacing `np.int`, you may wish to use e.g. `np.int64` or `np.int32` to specify the precision. If you wish to review your current use, check the release note link for additional information.
E           The aliases was originally deprecated in NumPy 1.20; for more details and guidance see the original release note at:
E               https://numpy.org/devdocs/release/1.20.0-notes.html#deprecations

/opt/miniconda3/envs/testbed/lib/python3.9/site-packages/numpy/__init__.py:319: AttributeError
=========================== short test summary info ============================
FAILED astropy/io/fits/tests/test_header.py::TestRecordValuedKeywordCards::test_fitsheader_script
FAILED astropy/io/fits/tests/test_header.py::TestRecordValuedKeywordCards::test_fitsheader_table_feature
======================== 2 failed, 150 passed in 1.28s =========================

the Check also fails on the tree as the run found it (baseline-check.log): nothing it says counts, the judge decides
scope: astropy/io/fits/header.py astropy/io/fits/card.py astropy/io/fits/tests
OUTSIDE THE SCOPE: CHANGES.rst +3 -0 (undo it: git checkout the file, or delete it when the run made it)
changed: astropy/io/fits/card.py +7 -5
changed: astropy/io/fits/header.py +9 -3
changed: astropy/io/fits/tests/test_header.py +26 -0
```

### `test-status.txt`

```
none
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

### `verdict.md`

```
verdict: PASS
`Header.fromstring` now decodes `bytes` data and separators before parsing, while `str` input bypasses the new branch.
`Card.fromstring` now decodes `bytes` input before the existing `_pad` handling, preserving `str` behavior.
The new tests cover both bytes and str inputs for `Header` and `Card`, matching the Done-when criteria.
The added changelog is outside the listed source scope but does not alter behavior.
```
