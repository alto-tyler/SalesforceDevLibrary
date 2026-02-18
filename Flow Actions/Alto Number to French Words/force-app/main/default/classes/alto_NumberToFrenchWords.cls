public class alto_NumberToFrenchWords {

    // ----- CONFIGURATION: All translations in constants -----
    private static final List<String> UNITS = new List<String>{
        '', 'un', 'deux', 'trois', 'quatre', 'cinq', 'six', 'sept', 'huit', 'neuf',
        'dix', 'onze', 'douze', 'treize', 'quatorze', 'quinze', 'seize'
    };

    private static final List<String> TENS = new List<String>{
        '', '', 'vingt', 'trente', 'quarante', 'cinquante', 'soixante'
    };

    private static final String CENT = 'cent';
    private static final String THOUSAND = 'mille';
    private static final String MILLION = 'million';
    private static final String SEP_ET = '-et-';
    private static final String SEP_HYPHEN = '-';

    // ----- PUBLIC METHOD: Convert decimal number to French words with dynamic currency -----
    public static String convert(Decimal inputNumber, String majorUnit, String minorUnit) {
        if (inputNumber == null) return 'zéro';

        Integer euros = Math.floor(inputNumber).intValue();
        Integer cents = Integer.valueOf(Math.round((inputNumber - euros) * 100));

        return convert(euros, cents, majorUnit, minorUnit);
    }

    // ----- NEW OVERLOAD: Convert using explicit euros/cents and dynamic currency -----
    public static String convert(Integer majorValue, Integer minorValue, String majorUnit, String minorUnit) {
        String majorPart = (majorValue != null && majorValue > 0) ? convertInt(majorValue, true) + ' ' + majorUnit + (majorValue > 1 ? 's' : '') : '';
        String minorPart = (minorValue != null && minorValue > 0) ? convertInt(minorValue, true) + ' ' + minorUnit + (minorValue > 1 ? 's' : '') : '';

        if (majorPart != '' && minorPart != '') return majorPart + ' et ' + minorPart;
        if (majorPart != '') return majorPart;
        if (minorPart != '') return minorPart;
        return 'zéro';
    }

    // ----- PRIVATE METHOD: Convert integer recursively with correct French rules -----
    private static String convertInt(Integer n, Boolean isEndOfGroup) {
        if (n == 0) return '';
        if (n < 17) return UNITS[n];
        else if (n < 20) return 'dix' + SEP_HYPHEN + UNITS[n - 10];
        else if (n < 70) {
            Integer ten = n / 10;
            Integer unit = n - ten * 10;
            String sep = (unit == 1 && ten != 8) ? SEP_ET : (unit > 0 ? SEP_HYPHEN : '');
            return TENS[ten] + sep + (unit > 0 ? UNITS[unit] : '');
        } else if (n < 80) { // 70-79
            if (n == 71) return 'soixante' + SEP_ET + 'onze';
            return 'soixante' + SEP_HYPHEN + convertInt(n - 60, true);
        } else if (n < 100) { // 80-99
            Integer unit = n - 80;
            String prefix = 'quatre-vingt';
            if (unit == 0) prefix += 's'; // add "s" for exact 80
            else prefix += SEP_HYPHEN + convertInt(unit, true);  // 81–99
            return prefix;
        } else if (n < 1000) {
            Integer hundreds = n / 100;
            Integer rest = n - hundreds * 100;
            String h = (hundreds == 1 ? CENT : UNITS[hundreds] + ' ' + CENT);
            if (hundreds > 1 && rest == 0 && isEndOfGroup) h += 's';
            if (rest > 0) h += ' ' + convertInt(rest, true);
            return h;
        } else if (n < 1000000) {
            Integer thousands = n / 1000;
            Integer rest = n - thousands * 1000;
            String t = (thousands == 1 ? THOUSAND : convertInt(thousands, false) + ' ' + THOUSAND);
            if (rest > 0) t += ' ' + convertInt(rest, true);
            return t;
        } else {
            Integer millions = n / 1000000;
            Integer rest = n - millions * 1000000;
            String m = (millions == 1 ? 'un ' + MILLION : convertInt(millions, false) + ' ' + MILLION + 's');
            if (rest > 0) m += ' ' + convertInt(rest, true);
            return m;
        }
    }

    // ----- INVOCABLE METHOD FOR FLOW -----
    public class Request {
        @InvocableVariable(required=true)
        public Decimal inputNumber;

        @InvocableVariable(required=true)
        public String majorUnit = 'euro';

        @InvocableVariable(required=true)
        public String minorUnit = 'centime';
    }

    public class Response {
        @InvocableVariable
        public String frenchWords;
    }

    @InvocableMethod(label='Convert Number to French Words' description='Converts a decimal number to French words for checks')
    public static List<Response> convertInvocable(List<Request> requests) {
        List<Response> results = new List<Response>();
        for (Request req : requests) {
            Response res = new Response();
            res.frenchWords = convert(req.inputNumber, req.majorUnit, req.minorUnit);
            results.add(res);
        }
        return results;
    }
}