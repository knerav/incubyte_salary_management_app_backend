module CurrencyLookup
  DEFAULT_COUNTRY = "IN"

  # Common ISO 4217 currency symbols. Covers all countries in seed data and
  # most of the world's major currencies.
  SYMBOLS = {
    "AED" => "د.إ", "AFN" => "؋",  "ALL" => "L",   "AMD" => "֏",
    "ANG" => "ƒ",   "AOA" => "Kz",  "ARS" => "$",   "AUD" => "A$",
    "AWG" => "ƒ",   "AZN" => "₼",  "BAM" => "KM",  "BBD" => "$",
    "BDT" => "৳",  "BGN" => "лв", "BHD" => ".د.ب", "BMD" => "$",
    "BND" => "$",   "BOB" => "Bs.", "BRL" => "R$",  "BSD" => "$",
    "BTN" => "Nu",  "BWP" => "P",   "BYN" => "Br",  "BZD" => "BZ$",
    "CAD" => "CA$", "CDF" => "Fr",  "CHF" => "Fr",  "CLP" => "$",
    "CNY" => "¥",   "COP" => "$",   "CRC" => "₡",  "CUP" => "$",
    "CVE" => "$",   "CZK" => "Kč",  "DJF" => "Fr",  "DKK" => "kr",
    "DOP" => "RD$", "DZD" => "دج",  "EGP" => "£",   "ERN" => "Nfk",
    "ETB" => "Br",  "EUR" => "€",   "FJD" => "$",   "GBP" => "£",
    "GEL" => "₾",  "GHS" => "₵",  "GIP" => "£",   "GMD" => "D",
    "GNF" => "Fr",  "GTQ" => "Q",   "GYD" => "$",   "HKD" => "HK$",
    "HNL" => "L",   "HRK" => "kn",  "HTG" => "G",   "HUF" => "Ft",
    "IDR" => "Rp",  "ILS" => "₪",  "INR" => "₹",  "IQD" => "ع.د",
    "IRR" => "﷼",  "ISK" => "kr",  "JMD" => "J$",  "JOD" => "JD",
    "JPY" => "¥",   "KES" => "KSh", "KGS" => "лв", "KHR" => "៛",
    "KMF" => "Fr",  "KPW" => "₩",  "KRW" => "₩",  "KWD" => "KD",
    "KYD" => "$",   "KZT" => "₸",  "LAK" => "₭",  "LBP" => "£",
    "LKR" => "₨",  "LRD" => "$",   "LSL" => "M",   "LYD" => "LD",
    "MAD" => "MAD", "MDL" => "L",   "MGA" => "Ar",  "MKD" => "ден",
    "MMK" => "K",   "MNT" => "₮",  "MOP" => "P",   "MRU" => "UM",
    "MUR" => "₨",  "MVR" => "Rf",  "MWK" => "MK",  "MXN" => "$",
    "MYR" => "RM",  "MZN" => "MT",  "NAD" => "$",   "NGN" => "₦",
    "NIO" => "C$",  "NOK" => "kr",  "NPR" => "₨",  "NZD" => "NZ$",
    "OMR" => "﷼",  "PAB" => "B/.", "PEN" => "S/.", "PGK" => "K",
    "PHP" => "₱",  "PKR" => "₨",  "PLN" => "zł",  "PYG" => "Gs",
    "QAR" => "﷼",  "RON" => "lei", "RSD" => "din", "RUB" => "₽",
    "RWF" => "Fr",  "SAR" => "﷼",  "SBD" => "$",   "SCR" => "₨",
    "SDG" => "ج.س.", "SEK" => "kr", "SGD" => "S$",  "SHP" => "£",
    "SLL" => "Le",  "SOS" => "S",   "SRD" => "$",   "SSP" => "£",
    "STN" => "Db",  "SVC" => "₡",  "SYP" => "£",   "SZL" => "E",
    "THB" => "฿",  "TJS" => "SM",  "TMT" => "T",   "TND" => "DT",
    "TOP" => "T$",  "TRY" => "₺",  "TTD" => "TT$", "TWD" => "NT$",
    "TZS" => "TSh", "UAH" => "₴",  "UGX" => "USh", "USD" => "$",
    "UYU" => "$U",  "UZS" => "лв", "VES" => "Bs.S","VND" => "₫",
    "VUV" => "VT",  "WST" => "WS$", "XAF" => "Fr",  "XCD" => "$",
    "XOF" => "Fr",  "XPF" => "Fr",  "YER" => "﷼",  "ZAR" => "R",
    "ZMW" => "ZK",  "ZWL" => "$"
  }.freeze

  # Returns the ISO 4217 currency code for a country alpha-2 code.
  def self.code_for(country_code)
    ISO3166::Country[country_code]&.currency_code
  end

  # Returns the currency symbol (e.g. "₹", "$") for a country alpha-2 code.
  # Falls back to the currency code string if no symbol mapping exists.
  def self.symbol_for(country_code)
    currency_code = code_for(country_code)
    return nil unless currency_code

    SYMBOLS[currency_code] || currency_code
  end
end
