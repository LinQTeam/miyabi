class String
  KATAKANA_TO_ROMAN_MAPPING = [
    ['キャ', 'kya'],
    ['キュ', 'kyu'],
    ['キョ', 'kyo'],
    ['シャ', 'sha'],
    ['シュ', 'shu'],
    ['ショ', 'sho'],
    ['チャ', 'cha'],
    ['チュ', 'chu'],
    ['チョ', 'cho'],
    ['ヂャ', 'ja'],
    ['ヂュ', 'ju'],
    ['ヂョ', 'jo'],
    ['ニャ', 'nya'],
    ['ニュ', 'nyu'],
    ['ニョ', 'nyo'],
    ['ヒャ', 'hya'],
    ['ヒュ', 'hyu'],
    ['ヒョ', 'hyo'],
    ['ミャ', 'mya'],
    ['ミュ', 'myu'],
    ['ミョ', 'myo'],
    ['リャ', 'rya'],
    ['リュ', 'ryu'],
    ['リョ', 'ryo'],
    ['ギャ', 'gya'],
    ['ギュ', 'gyu'],
    ['ギョ', 'gyo'],
    ['ジャ', 'ja'],
    ['ジュ', 'ju'],
    ['ジョ', 'jo'],
    ['ビャ', 'bya'],
    ['ビュ', 'byu'],
    ['ビョ', 'byo'],
    ['ピャ', 'pya'],
    ['ピュ', 'pyu'],
    ['ピョ', 'pyo'],
    ['ヴァ', 'va'],
    ['ヴィ', 'vi'],
    ['ヴェ', 've'],
    ['ヴォ', 'vo'],
    ['ファ', 'fa'],
    ['フィ', 'fi'],
    ['フェ', 'fe'],
    ['フォ', 'fo'],
    ['ア', 'a'],
    ['イ', 'i'],
    ['ウ', 'u'],
    ['エ', 'e'],
    ['オ', 'o'],
    ['カ', 'ka'],
    ['キ', 'ki'],
    ['ク', 'ku'],
    ['ケ', 'ke'],
    ['コ', 'ko'],
    ['サ', 'sa'],
    ['シ', 'shi'],
    ['ス', 'su'],
    ['セ', 'se'],
    ['ソ', 'so'],
    ['タ', 'ta'],
    ['チ', 'chi'],
    ['ツ', 'tsu'],
    ['テ', 'te'],
    ['ト', 'to'],
    ['ナ', 'na'],
    ['ニ', 'ni'],
    ['ヌ', 'nu'],
    ['ネ', 'ne'],
    ['ノ', 'no'],
    ['ハ', 'ha'],
    ['ヒ', 'hi'],
    ['フ', 'fu'],
    ['ヘ', 'he'],
    ['ホ', 'ho'],
    ['マ', 'ma'],
    ['ミ', 'mi'],
    ['ム', 'mu'],
    ['メ', 'me'],
    ['モ', 'mo'],
    ['ヤ', 'ya'],
    ['ユ', 'yu'],
    ['ヨ', 'yo'],
    ['ラ', 'ra'],
    ['リ', 'ri'],
    ['ル', 'ru'],
    ['レ', 're'],
    ['ロ', 'ro'],
    ['ワ', 'wa'],
    ['ヰ', 'i'],
    ['ヱ', 'e'],
    ['ヲ', 'o'],
    ['ン', 'n'],
    ['ガ', 'ga'],
    ['ギ', 'gi'],
    ['グ', 'gu'],
    ['ゲ', 'ge'],
    ['ゴ', 'go'],
    ['ザ', 'za'],
    ['ジ', 'ji'],
    ['ズ', 'zu'],
    ['ゼ', 'ze'],
    ['ゾ', 'zo'],
    ['ダ', 'da'],
    ['ヂ', 'ji'],
    ['ヅ', 'zu'],
    ['デ', 'de'],
    ['ド', 'do'],
    ['バ', 'ba'],
    ['ビ', 'bi'],
    ['ブ', 'bu'],
    ['ベ', 'be'],
    ['ボ', 'bo'],
    ['パ', 'pa'],
    ['ピ', 'pi'],
    ['プ', 'pu'],
    ['ペ', 'pe'],
    ['ポ', 'po'],
    ['ヴ', 'vu'],
    ['ー', '-'],
    ['0', '0'],
    ['1', '1'],
    ['2', '2'],
    ['3', '3'],
    ['4', '4'],
    ['5', '5'],
    ['6', '6'],
    ['7', '7'],
    ['8', '8'],
    ['9', '9'],
    ['０', '0'],
    ['１', '1'],
    ['２', '2'],
    ['３', '3'],
    ['４', '4'],
    ['５', '5'],
    ['６', '6'],
    ['７', '7'],
    ['８', '8'],
    ['９', '9']
  ].freeze
  private_constant :KATAKANA_TO_ROMAN_MAPPING

  def to_kana
    self.tr('ぁ-ん','ァ-ン')
  end

  def to_hira
    self.tr('ァ-ン','ぁ-ん')
  end

  # ひらがな・カタカナ・全角数字・長音符などが連続する区間だけをまとめて扱い、
  # そこだけローマ字化してそれ以外は原文のまま残すためのパターン。
  JAPANESE_CHUNK_PATTERN = /[ぁ-ゖゝゞァ-ヺ０-９ー]+/.freeze
  private_constant :JAPANESE_CHUNK_PATTERN

  def to_roman
    return self if self.is_roman?

    # 日本語の塊とそれ以外を交互に抜き出し、日本語部分だけローマ字変換する
    self.scan(/[ぁ-ゖゝゞァ-ヺ０-９ー]+|[^ぁ-ゖゝゞァ-ヺ０-９ー]+/).map do |chunk|
      if chunk.match?(JAPANESE_CHUNK_PATTERN)
        romanize_katakana_segment(chunk)
      else
        chunk
      end
    end.join
  end

  private

  # カタカナ列を最長一致でトークン化し、促音を意識しつつ順番にローマ字へ写像する
  def romanize_katakana_segment(segment)
    tokens = tokenize_katakana(segment.to_kana)
    index = 0
    result = +""

    while index < tokens.length
      token = tokens[index]

      if token == 'ッ'
        # 小さい「ッ」は直後のトークンの子音を重ねるか、対象が無ければ「xtsu」を挿入
        doubled = romanize_sokuon(tokens[index + 1])
        result << doubled[:roman]
        tokens[index + 1] = doubled[:next_token] if doubled[:next_token]
      else
        result << romanize_token(token)
      end

      index += 1
    end

    result
  end

  def tokenize_katakana(katakana)
    tokens = []
    index = 0

    while index < katakana.length
      match = KATAKANA_TO_ROMAN_MAPPING.find { |kana_key, _| katakana[index, kana_key.length] == kana_key }

      if match
        kana_key, _ = match
        tokens << kana_key
        index += kana_key.length
      else
        tokens << katakana[index]
        index += 1
      end
    end

    tokens
  end
  private :tokenize_katakana

  def romanize_token(token)
    match = KATAKANA_TO_ROMAN_MAPPING.find { |kana_key, _| kana_key == token }
    match ? match[1] : token
  end
  private :romanize_token

  # 促音の直後に続くトークンを調べ、子音重複が可能なら反映し、難しければ「xtsu」を返す
  def romanize_sokuon(next_token)
    return { roman: 'xtsu' } unless next_token

    roman = romanize_token(next_token)
    return { roman: 'xtsu' } if roman.empty?

    first = roman[0]
    return { roman: 'xtsu' + roman } unless first.match?(/[a-z]/)
    return { roman: 'xtsu' + roman } if first == 'x'

    { roman: first + roman, next_token: next_token.sub(/\A./, '') }
  end
end
