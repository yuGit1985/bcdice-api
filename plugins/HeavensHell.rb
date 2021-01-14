# -*- coding: utf-8 -*-
# frozen_string_literal: true

require 'utils/table.rb'

class HeavensHell < DiceBot
  # ゲームシステムの識別子
  ID = 'HeavensHell'

  # ゲームシステム名
  NAME = 'ヘブンズヘル'

  # ゲームシステム名の読みがな
  SORT_KEY = 'へふんすへる'

  # ダイスボットの使い方
  HELP_MESSAGE = <<INFO_MESSAGE_TEXT
・各種表
　・(無印)シーン表　ST／ファンブル表　FT／感情表　ET
　　　／変調表　WT／戦場表　BT／異形表　MT／ランダム特技決定表　RTT
　・(弐)都市シーン表　CST／館シーン表　　MST／出島シーン表　DST
　・(参)トラブルシーン表　TST／日常シーン表　NST／回想シーン表　KST
　・(死)東京シーン表　TKST／戦国シーン表　GST
　・(乱)戦国変調表　GWT
　・(リプレイ戦1〜2巻)学校シーン表　GAST／京都シーン表　KYST
　　　／神社仏閣シーン表　JBST
　・(怪)怪ファンブル表　KFT／怪変調表　KWT
　・（その他）秋空に雪舞えばシーン表　AKST／災厄シーン表　CLST
　　／出島EXシーン表　DXST／斜歯ラボシーン表　HLST
　　／夏の終わりシーン表　NTST／培養プラントシーン表　　PLST
　　・忍秘伝　　中忍試験シーン表　HC/滅びの塔シーン表　HT/影の街でシーン表　HK
　　/夜行列車シーン表　HY/病院シーン表　HO/龍動シーン表　HR/密室シーン表　HM/催眠シーン表　HS
・D66ダイスあり
INFO_MESSAGE_TEXT

  def initialize
    super
    @sendMode = 2
    @sortType = 1
    @d66Type = 2
  end

  def check_2D6(total, dice_total, _dice_list, cmp_op, target)
    return '' unless cmp_op == :>=

    if dice_total <= 2
      " ＞ ファンブル"
    elsif dice_total >= 12
      " ＞ スペシャル"
    elsif total >= target
      " ＞ 成功"
    else
      " ＞ 失敗"
    end
  end

  def rollDiceCommand(command)
    string = command.upcase

    result = roll_tables(command, TABLES)
    if result
      return result
    end

    case string
    when /\w*RTT/ # ランダム特技決定表
      return sinobigami_random_skill_table()
    when 'MT' # 異形表
      return sinobigami_metamorphose_table()
    end

    return nil
  end

  private

  # ランダム指定特技表
  def sinobigami_random_skill_table()
    skill_table, value1 = get_table_by_1d6(RANDOM_SKILL_TABLE)
    table_name, skill_table = skill_table
    skill, value2 = get_table_by_2d6(skill_table)

    return "ランダム指定特技表(#{value1},#{value2}) ＞ 『#{table_name}』#{skill}"
  end

  # 異形表
  def sinobigami_metamorphose_table()
    text, value = get_table_by_1d6(METAMORPHOSE_TABLE)
    output = "異形表(#{value}) ＞ #{text}"

    if (demon_skill_table = DEMON_SKILL_TABLES[value - 1])
      text, = get_table_by_1d6(demon_skill_table[:table])
      output += " #{demon_skill_table[:name]} ＞ #{text}#{demon_skill_table[:page]}"
    end

    return output
  end

  TABLES = {
    'ST' => Table.new(
      'シーン表',
      '2D6',
      [
        '血の臭いがあたりに充満している。何者かの戦いがあった気配。　いや？まだ戦いは続いているのだろうか？',
        'これは……夢か？　もう終わったはずの過去。しかし、それを忘れることはできない。',
        '眼下に広がる街並みを眺める。ここからなら街を一望できるが……。',
        '世界の終わりのような暗黒。暗闇の中、お前達は密やかに囁く。',
        '優しい時間が過ぎていく。影の世界のことを忘れてしまいそうだ。',
        '清廉な気配が漂う森の中。鳥の囀りや、そよ風が樹々を通り過ぎる音が聞こえる。',
        '凄まじい人混み。喧噪。影の世界のことを知らない無邪気な人々の手柄話や無駄話が騒がしい。',
        '強い雨が降り出す。人々は、軒を求めて、大慌てて駆けだしていく。',
        '大きな風が吹き荒ぶ。髪の毛や衣服が大きく揺れる。何かが起こりそうな予感……',
        '酔っぱらいの怒号。客引きたちの呼び声。女たちの嬌声。いつもの繁華街の一幕だが。',
        '太陽の微笑みがあなたを包み込む。影の世界の住人には、あまりにまぶしすぎる。',
      ]
    ),
    'CST' => Table.new(
      '都市シーン表',
      '2D6',
      [
        'シャワーを浴び、浴槽に疲れた身体を沈める。時には、癒しも必要だ。',
        '閑静な住宅街。忍びの世とは関係のない日常が広がっているようにも見えるが……それも錯覚なのかもしれない',
        '橋の上にたたずむ。川の対岸を結ぶ境界点。さて、どちらに行くべきか……？',
        '人気のない公園。野良猫が一匹、遠くからあなたを見つめているような気がする。',
        '至福の一杯。この一杯のために生きている……って、いつも言ってるような気がするなぁ。',
        '無機質な感じのするオフィスビル。それは、まるで都市の墓標のようだ。',
        '古びた劇場。照明は落ち、あなたたちのほかに観客の姿は見えないが……。',
        '商店街を歩く。人ごみに混じって、不穏な気配もちらほら感じるが……。',
        'ビルの谷間を飛び移る。この街のどこかに、「アレ」は存在するはずなのだが……。',
        '見知らぬ天井。いつの間にか眠っていたのだろうか？それにしてもここはどこだ？',
        '廃屋。床には乱雑に壊れた調度品や器具が転がっている。',
      ]
    ),
    'MST' => Table.new(
      '館シーン表',
      '2D6',
      [
        'どことも知れぬ暗闇の中。忍びの者たちが潜むには、おあつらえ向きの場所である。',
        '洋館の屋根の上。ここからなら、館の周りを一望できるが……。',
        '美しい庭園。丹精こめて育てられたであろう色とりどりの花。そして、綺麗に刈り込まれた生垣が広がっている。',
        'あなたは階段でふと足を止めた。何者かの足音が近づいているようだ。',
        'あなたに割り当てられた寝室。ベッドは柔らかく、調度品も高級なものばかりだが……。',
        'エントランスホール。古い柱時計の時報が響く中、館の主の肖像画が、あなたを見下ろしている。',
        '食堂。染み一つないテーブルクロスに覆われた長い食卓。その上は年代物の燭台や花で飾られている。',
        '長い廊下の途中。この屋敷は広すぎて、迷子になってしまいそうだ。',
        '戯れに遊戯室へ入ってみた。そこには撞球台やダーツの的、何組かのトランプが散らばっているポーカーテーブルがあった。',
        'かび臭い図書室。歴代の館の主たちの記録や、古今東西の名著が、ぎっしりと棚に並べられている。',
        '一族の納骨堂がある。冷気と瘴気に満ちたその場所に、奇妙な叫びが届く。遠くの鳥のさえずりか？それとも死者の恨みの声か……？',
      ]
    ),
    'DST' => Table.new(
      '出島シーン表',
      '2D6',
      [
        '迷宮街。いつから囚われてしまったのだろう？何重にも交差し、曲がりくねった道を歩き続ける。このシーンの登場人物は《記憶術》で判定を行わなければならない。成功すると、迷宮の果てで好きな忍具を一つ獲得する。失敗すると、行方不明の変調を受ける。',
        '幻影城。訪れた者の過去や未来の風景を見せる場所。このシーンの登場人物は、《意気》の判定を行うことができる。成功すると、自分の持っている【感情】を好きな何かに変更することができる。',
        '死者たちの行進。無念の死を遂げた者たちが、仲間を求めて彷徨らっている。このシーンの登場人物は《死霊術》で判定を行わなければならない。失敗すると、ランダムに変調を一つを受ける。',
        'スラム。かろうじて生き延びている人たちが肩を寄せ合い生きているようだ。ここなら辛うじて安心できるかも……。',
        '落書きだらけのホテル。その周囲には肌を露出させた女や男たちが、媚態を浮かべながら立ち並んでいる。',
        '立ち並ぶ廃墟。その影から、人とも怪物ともつかぬ者の影が、あなたの様子をじっとうかがっている。',
        '薄汚い路地裏。巨大な黒犬が何かを貪っている。あなたの気配を感じて黒犬は去るが、そこに遺されていたのは……。',
        '昏い酒場。バーテンが無言でグラスを磨き続けている。あなたの他に客の気配はないが……。',
        '地面を覆う無数の瓦礫。その隙間から暗黒の瘴気が立ち昇る。このシーンの登場人物は《生存術》で判定を行わなければならない。失敗すると、好きな【生命力】を１点失う。',
        '熱気溢れる市場。武器や薬物などを売っているようだ。商人たちの中には、渡来人の姿もある。このシーンの登場人物は、《経済力》で判定を行うことができる。成功すると、好きな忍具を一つ獲得できる。',
        '目の前に渡来人が現れる。渡来人はあなたに興味を持ち、襲い掛かってくる。このシーンの登場人物は《刀術》で判定を行わなければならない。成功すると、渡来人を倒し、好きな忍具を一つ獲得する。失敗すると、３点の接近戦ダメージを受ける。',
      ]
    ),
    'TST' => Table.new(
      'トラブルシーン表',
      '2D6',
      [
        '同行者とケンカしてしまう。うーん、気まずい雰囲気。',
        'バシャ！　同行者のミスでずぶ濡れになってしまう。……冷たい。',
        '敵の気配に身を隠す。……すると、同行者の携帯が着信音を奏で始める。「……えへへへへ」じゃない！',
        '同行者の空気の読めない一言。場が盛大に凍り付く。まずい。何とかしないと。',
        '危機一髪！　同行者を死神の魔手から救い出す。……ここも油断できないな。',
        '同行者が行方不明になる。アイツめ、どこへ逃げたッ！',
        'ずて────ん！　あいたたたた……同行者がつまずいたせいで、巻き込まれて転んでしまった。',
        '同行者のせいで、迷子になってしまう。困った。どこへ行くべきか。',
        '「どこに目つけてんだ、てめぇ！」同行者がチンピラにからまれる。うーん、助けに入るべきか。',
        '！　油断していたら、同行者に自分の恥ずかしい姿を見られてしまう。……一生の不覚！',
        '同行者が不意に涙を流す。……一体、どうしたんだろう？',
      ]
    ),
    'NST' => Table.new(
      '日常シーン表',
      '2D6',
      [
        'っくしゅん！　……うーん、風邪ひいたかなあ。お見舞いに来てくれたんだ。ありがとう。',
        '目の前のアイツは、見違えるほどドレスアップしていた。……ゆっくりと大人な時間が過ぎていく。',
        'おいしそうなスイーツを食べることになる。たまには甘いものを食べて息抜き息抜き♪',
        'ふわわわわ、いつの間にか寝ていたようだ。……って、あれ？　お前、いつからそこにいたッ!!',
        '買い物帰りの友人と出会う。方向が同じなので、しばらく一緒に歩いていると、思わず会話が盛り上がる。',
        'コンビニ。商品に手を伸ばしたら、同時にその商品をとろうとした別の人物と手が触れあう。なんという偶然！',
        'みんなで食卓を囲むことになる。鍋にしようか？　それとも焼き肉？　お好み焼きなんかもい〜な〜♪',
        'どこからか楽しそうな歌声が聞こえてくる。……って、あれ？　何でお前がこんなところに？',
        '野良猫に餌をやる。……猫はのどを鳴らし、すっかりあなたに甘えているようだ。',
        '「……！　……？　……♪」テレビは、なにやら楽しげな場面を映している。あら。もう、こんな時間か。',
        '面白そうなゲーム！　誰かと対戦することになる。GMは、「戦術」からランダムに特技1つを選ぶ。このシーンに登場しているキャラクターは、その特技の判定を行う。成功した場合、同じシーンに登場しているキャラクターを1人を選び、そのキャラクターの自分に対する【感情】を好きなものに変更する（何の【感情】も持っていない場合、好きな【感情】を芽生えさせる）。',
      ]
    ),
    'TKST' => Table.new(
      '東京シーン表',
      '2D6',
      [
        'お台場、臨界副都心。デート中のカップルや観光客が溢れている。',
        '靖国神社。東京の中とも思えぬ、緑で満ちた場所だ。今は観光客もおらず、奇妙に静かだ……。',
        '東京大学の本部キャンパス。正門から伸びる銀杏並木の道を学生や教職員がのんびりと歩いている。道の向こうには安田講堂が見える。',
        '山手線の中。乗車率200％を超える、殺人的な通勤ラッシュ真っ最中。この中でできることは限られている……。',
        '霞が関。この場に集う情報は、忍者にとっても価値が高いものだ。道を行く人々の中にも、役人や警察官が目につく。',
        '渋谷駅前の雑踏。大型屋外ヴィジョンが見下ろす中で、大勢の若者たちが行き交っている。',
        '夜の新宿歌舞伎町。酔っぱらったサラリーマン、華やかな夜の蝶、明らかに筋ものと判る男、外国人などの様々な人間と、どこか危険な雰囲気に満ちている。',
        '新宿都庁。摩天楼が林立するビル街の下、背広姿の人々が行き交う。',
        '神田古書街。多くの古書店が軒を連ねている。軒先に積まれた本の山にさえ、追い求める謎や、深遠な知識が埋もれていそうな気がする。',
        '山谷のドヤ街。日雇い労働者が集う管理宿泊施設の多いこの場所は、身を隠すにはうってつけだ。',
        '東京スカイツリーの上。この場所からならば東京の町が一望できる。',
      ]
    ),
    'KST' => Table.new(
      '回想シーン表',
      '2D6',
      [
        '闇に蔓延する忍びの気配。あのときもそうだった。手痛い失敗の記憶。今度こそ、うまくやってみせる。',
        '甘い口づけ。激しい抱擁。悲しげな瞳……一夜の過ちが思い返される。',
        '記憶の中でゆらめくセピア色の風景。……見覚えがある。そう、私はここに来たことがあるはずだッ!!',
        '目の前に横たわる死体。地面に広がっていく。あれは、私のせいだったのだろうか……？',
        'アイツとの大切な約束を思い出す。守るべきだった約束。果たせなかった約束。',
        '助けを求める右手が、あなたに向かってまっすぐ伸びる。あなたは、必死でその手を掴もうとするが、あと一歩のところで、その手を掴み損ねる……。',
        'きらきらと輝く笑顔。今はもう喪ってしまった、大事だったアイツの笑顔。',
        '恐るべき一撃！　もう少しで命を落とすところだった……。しかし、あの技はいまだ見切れていない。',
        '幼い頃の記憶。仲の良かったあの子。そういえば、あの子は、どこに行ってしまったのだろう。もしかして……。',
        '「……ッ!!」激しい口論。ひどい別れ方をしてしまった。あんなことになると分かっていたら……。',
        '懐の中のお守りを握りしめる。アイツにもらった、大切な思い出の品。「兵糧丸」を1つ獲得する。',
      ]
    ),
    'GST' => Table.new(
      '戦国シーン表',
      '2D6',
      [
        '炎上する山城。人々の悲鳴や怒号がこだましている。どうやら、敵対する武将による焼き討ちらしい。今ならば、あるいは……。',
        '荒れ果てた村。カラスの不吉な鳴き声が聞こえてくる中で、やせ細った村人たちが、うつろな瞳でこちらを伺っている。',
        '人気のない山道。ただ鳥の声だけが響いている。通りがかった人を襲うのには、好都合かもしれない。',
        '乾いた骸の転がる合戦後。生き物の姿はなく、草の一本さえも生えていない。落ち武者たちの恨みがましい声が聞こえてきそうだ……。',
        '不気味な気配漂う森の中。何か得体のしれぬものが潜んでいそうだ。',
        '荒れ果てた廃寺。ネズミがカサカサと這いまわる本堂の中を、残された本尊が見下ろしている。',
        '街道沿いの宿場町。戦から逃げてきたらしい町人や、商売の種を探す商人、目つきの鋭い武士などが行き交い、賑わっている。',
        '城の天守閣のさらに上。強く吹く風が、雲を流していく。',
        '館の天井裏。この下では今、何が行われているのか……。',
        '合戦場に設けられた陣内。かがり火がたかれ、武者たちが酒宴を行っている。',
        '戦の真っただ中にある合戦場。騎馬にまたがった鎧武者が駆け抜けていく。勝者となるのは、いずれの陣営だろうか。',
      ]
    ),
    'GAST' => Table.new(
      '学校シーン表',
      '2D6',
      [
        '清廉な気配が漂う森の中。鳥のさえずりやそよ風が木々を通りすぎる音が聞こえる。',
        '学校のトイレ。……なんだか少しだけ怖い気がする。',
        '誰もいない体育館。バスケットボールがころころと転がっている。',
        '校舎の屋上。一陣の風が吹き、衣服をたなびかせる。',
        '校庭。体操服姿の生徒たちが走っている。',
        '廊下。休憩時間か放課後か。生徒たちが、楽しそうにはしゃいでいる。',
        '学食のカフェテリア。生徒たちがまばらに席につき、思い思い談笑している。',
        '静かな授業中の風景。しかし、忍術を使って一般生徒に気取られない会話をしている忍者たちもいる。',
        '校舎と校舎をつなぐ渡り廊下。あなた以外の気配はないが……。',
        '特別教室。音楽室や理科室にいるのってなんか楽しいよね。',
        'プール。水面が、ゆらゆら揺れている。',
      ]
    ),
    'KYST' => Table.new(
      '京都シーン表',
      '2D6',
      [
        '夜の街並み。神社仏閣はライトアップされ、にぎやかな酔客が通りを埋める。昼間とはまた違った景色が広がっている。',
        '京都駅ビル。その屋上は、京都市で最も高く、周囲を一望できる。',
        '旅館で一休み。……のはずが、四方山話に花が咲く。',
        '鴨川のあたりを歩いている。カップルが均等に距離を置いて座っているのが面白い。',
        '京都はどこにでもおみやげ物屋があるなぁ。さて、あいつに何を買ってやるべきか……？',
        '「神社仏閣シーン表(JBST)」で決定。',
        '新京極でお買い物。アーケードには、新旧様々な店が建ち並ぶ。',
        '大学が近くにあるのかな？　安い定食屋や古本屋、ゲームセンターなどが軒を連ねる学生街。京都はたくさん大学があるなぁ。',
        '静かな竹林。凛とした気配が漂う。',
        '祇園。時折、しずしずと歩く舞妓さんとすれ違う。雰囲気のある町並みだ。',
        '一般公開された京都御所の中を歩く。昼間だというのに人通りはあまりなく、何だか少し寂しい気持ち。',
      ]
    ),
    'JBST' => Table.new(
      '神社仏閣シーン表',
      '2D6',
      [
        '清明神社。一条戻り橋を越えたところにある小さな社。陰陽師に憧れる女性たちの姿が目立つ。',
        '東寺。東寺真言宗総本山。密教独特の厳しい気配が漂う。',
        '平安神宮。大鳥居を白無垢の花嫁行列がくぐり抜けていくのが見える。どうやら結婚式のようだ。',
        '慈照寺――通称、銀閣寺。室町後期の東山文化を代表する建築である。錦鏡池を囲む庭園には、物思いにふける観光客の姿が……。',
        '鹿苑寺――通称、金閣寺。室町前期の北山文化を代表する建築である。鏡湖池に映る逆さ金閣には、強力な「魔」を封印していると言うが……？',
        '三十三間堂。荘厳な本堂に立ち並ぶ千一体の千手観音像は圧巻。',
        '清水寺。清水坂を越え、仁王門を抜けると、本堂――いわゆる清水の舞台にたどり着く。そこからは、音羽の滝や子安塔が見える。',
        '八坂神社。祇園さんの名前で知られるにぎやかな神社。舞妓さんの姿もちらほら。',
        '伏見稲荷。全国約四万社の稲荷神社の総本宮。稲荷山に向かって立ち並ぶ約一万基の鳥居は、まるで異界へと続いているかのようだ……。',
        '化野念仏寺。無数の石塔、石仏が立ち並ぶ景色は、どこか荒涼としている……。',
        '六道珍皇寺。小野篁が冥界に通ったとされる井戸のある寺。この辺りは「六道の辻」と呼ばれ、不思議な伝説が数多く残っている。',
      ]
    ),
    'AKST' => Table.new(
      '秋空に雪舞えばシーン表',
      '2D6',
      [
        'どこから紛れ込んできたのか。シーンプレイヤーが1D6を振って3以下ならナタを持った少女、4以上なら冬篭りに備えた熊が襲ってくる。シーンに登場したキャラクターは、少女なら《刀術》・熊なら《鳥獣術》で判定し、失敗すると接近戦ダメージを1点受ける。',
        '3:暗い夜の森の中、月明かりのみが周囲を照らす。忍が動くにはいい時間だ。',
        '4:秋晴れの下、両脇で黄金色の稲穂が風に靡く道。刈り取りを控えたこの短い間にしか見る事の出来ない貴重な光景だ。',
        '5:美味しそうな果実がたわわに実っている。一つくらい取って行ってもバチは当たらないだろう…。',
        '6:山中に続く林道。勾配の厳しい道から、紅葉が浮かび流れる穏やかな川が見下ろせる。',
        '7:村の広場。山や田畑が一望できる。波打つ稲穂の絨毯、山々には紅葉。秋を感じるひと時だ。',
        '8:パチパチと爆ぜる音。どうやら籾殻で焚き火をしているらしい。少し暖まっていこうか。',
        '9:神秘的な神社。祭りの準備が進められているが、今は人がいないようだ。',
        'ひと雨きそうな午後。重たい空気にキンモクセイがつと香る。',
        '草に埋もれ、崩れかけの古い空き家。どこか物悲しさを感じる。',
        'カツーン、カツーン、誰かが丑の刻参りをしている音が聞こえる。シーンに登場したキャラクターは《呪術》で判定し、成功すると誰かに《呪い》の変調を与えることができる。失敗すると《呪い》の変調を受ける。',
      ]
    ),
    'CLST' => Table.new(
      '災厄シーン表',
      '1D6',
      [
        '瘴気に晒され続けたことであなたの身体が妖魔へと変貌する。《封術》の判定に失敗したシーンプレイヤーは、背景：劣勢因子と背景：魔人を獲得する。',
        '妖魔があなたに従属を強いる。やつが掲げた手の中には…。《遁走術》の判定に失敗したシーンプレイヤーは、背景：人質と兵糧丸１つを獲得する。',
        '妖魔の群れに捕まった！独力での包囲網突破のために君の体は限界を迎えようとしていた。《拷問術》の判定に失敗したシーンプレイヤーは、背景：侵食と神通丸１つを獲得する。',
        '戦いの激化はあなたの体を蝕む。《医術》の判定に失敗したシーンプレイヤーは、背景：病魔と神通丸１つを獲得する。',
        '下級妖魔を束ねたボスが、新たなる力を手に入れようとしている。シーンプレイヤーが《見敵術》の判定に失敗した場合、ボスに対してエニグマ：『秘奥義』が公開状態で追加される。',
        '力なき者が生き残ることは出来ない。ボスが新たな力を手に入れようとしている。シーンプレイヤーが《怪力》の判定に失敗した場合、ボスに対してエニグマ：『八面六臂』が公開状態で追加される。',
      ]
    ),
    'DXST' => Table.new(
      '出島EXシーン表',
      '2D6',
      [
        '迷宮街。いつから囚われてしまったのだろう？何重にも交差し、曲がりくねった道を歩き続ける。このシーンの登場人物は《記憶術》で判定を行わなければならない。成功すると、迷宮の果てで好きな忍具を一つ獲得する。失敗すると、行方不明の変調を受ける。',
        '幻影城。訪れた者の過去や未来の風景を見せる場所。このシーンの登場人物は、《意気》の判定を行うことができる。成功すると、自分の持っている【感情】を好きな何かに変更することができる。',
        '死者たちの行進。無念の死を遂げた者たちが、仲間を求めて彷徨らっている。このシーンの登場人物は《死霊術》で判定を行わなければならない。失敗すると、ランダムに変調を一つを受ける。',
        'スラム。かろうじて生き延びている人たちが肩を寄せ合い生きているようだ。ここなら辛うじて安心できるかも……。',
        '落書きだらけのホテル。その周囲には肌を露出させた女や男たちが、媚態を浮かべながら立ち並んでいる。',
        '立ちふさがるのは妖魔の群れ。他に道などない、真正面から突き進むほかは…災厄シーン表(CLST)を振ること。',
        '薄汚い路地裏。巨大な黒犬が何かを貪っている。あなたの気配を感じて黒犬は去るが、そこに遺されていたのは……。',
        '昏い酒場。バーテンが無言でグラスを磨き続けている。あなたの他に客の気配はないが……。',
        '地面を覆う無数の瓦礫。その隙間から暗黒の瘴気が立ち昇る。このシーンの登場人物は《生存術》で判定を行わなければならない。失敗すると、好きな【生命力】を１点失う。',
        '熱気溢れる市場。武器や薬物などを売っているようだ。商人たちの中には、渡来人の姿もある。このシーンの登場人物は、《経済力》で判定を行うことができる。成功すると、好きな忍具を一つ獲得できる。',
        '目の前に渡来人が現れる。渡来人はあなたに興味を持ち、襲い掛かってくる。このシーンの登場人物は《刀術》で判定を行わなければならない。成功すると、渡来人を倒し、好きな忍具を一つ獲得する。失敗すると、３点の接近戦ダメージを受ける。',
      ]
    ),
    'HC' => Table.new(
      '中忍試験シーン表',
      '2D6',
      [
        '深い闇が辺りを覆う。何度目かの夜……いつまでこの試験は続くのだろう。このシーンに登場するキャラクターは《生存術》で判定を行い、失敗すると集団戦ダメージを1点受ける。',
        '山の冷気が肉体を蝕む。このシーンに登場するキャラクターは《衣装術》で判定を行い、失敗すると射撃戦ダメージを1受ける。',
        '腹を空かせた獣が襲いかかってくる。このシーンに登場するキャラクターは、《鳥獣術》で判定を行い、失敗すると射撃戦ダメージを1点受ける。',
        '上忍の仕掛けたトラップが発動。このシーンに登場するキャラクターは《罠術》で判定を行い、失敗すると射撃戦ダメージを1点受ける。',
        '濃い霧が出てきた。視界が極端に悪くなり、不安を感じる……。',
        '清廉な気配が漂う森の中。鳥のさえずりや、そよ風が木々を通り過ぎる音が聞こえる。',
        '朽ちた山小屋を発見する。何年も使った様子はなさそうだが……。',
        '山の天気は変わりやすい。嵐がやってくる。今後、戦闘が発生したとき、戦場表を使わなかった場合、その戦場は「平地」ではなく「悪天候」として扱う。',
        'ひときわ高くなっている尾根にたどり着く。このシーンの登場するキャラクターは、《登術》で判定を行い、成功すると、好きなキャラクター1人の【居所】を獲得する。',
        '深山幽谷（しんざんゆうこく）の果てに、清涼な泉を発見する。ふう、生き返るな。このシーンに登場するキャラクターは、《意気》の判定に成功すると、【生命力】を1点回復させることができる。',
        '脱落した別のグループの忍者の死体を発見する。こいつらには、もう不要だろう。好きな忍具1つを獲得する。（何を獲得するか宣言すること）。',
      ]
    ),
    'HK' => Table.new(
      '影の街でシーン表',
      '2D6',
      [
        '血の臭いがあたりに充満している。何者かの戦いがあった気配。　いや？まだ戦いは続いているのだろうか？',
        'これは……夢か？　もう終わったはずの過去。しかし、それを忘れることはできない。',
        '眼下に広がる街並みを眺める。ここからなら街を一望できるが……。',
        '世界の終わりのような暗黒。暗闇の中、お前達は密やかに囁く。',
        '死者たちの行進。無念の死を遂げた者たちが、死者を求めて彷徨っている。このシーンの登場人物は《死霊術》で判定を行わなければいけない。失敗すると、ランダムに変調1つを受ける。',
        '立ち並ぶ廃墟。その影から、人とも怪物ともつかない者の影が、あなたの様子を窺っている。',
        '地面を覆う瓦礫。その隙間から暗黒の瘴気が立ち昇る。このシーンの登場人物は、《生存術》で判定を行わなければならない。失敗すると好きな【生命力】1点を失う。',
        '強い雨が降り出す。人々は、軒を求めて、大慌てて駆けだしていく。',
        '大きな風が吹き荒ぶ。髪の毛や衣服が大きく揺れる。何かが起こりそうな予感……',
        '酔っぱらいの怒号。客引きたちの呼び声。女たちの嬌声。いつもの繁華街の一幕だが。',
        '太陽の微笑みがあなたを包み込む。影の世界の住人には、あまりにまぶしすぎる。',
      ]
    ),
    'HLST' => Table.new(
      '斜歯ラボシーン表',
      '2D6',
      [
        '今週のびっくりどっくり斜歯開発室、1D6を振り奇数なら好きな忍具が入手できる。偶数でも好きな忍具が入手できるが、射撃戦ダメージを１点受ける。',
        'トランスポーターだ！《絡繰術》で判定すること。失敗するとどこかへ飛ばされて《行方不明》の変調を受ける。成功した場合、望む場所へ到達できる。好きな「居所」を入手すること。',
        '改造室。調整途中の下忍戦闘員たちが錯乱し、あなたに襲い掛かる。〈傀儡術〉の判定を行う。失敗すると1点の集団戦ダメージを受ける。成功すれば「居所」を持っている他のキャラクターに1点の集団戦ダメージを与えることができる。',
        'エレベーター。ただし四方八方へ移動する。行き先ボタンは無い。この箱はこれから何処へ行くのか。',
        '長く続く廊下。不気味なほどに静まり返っているが、周囲からはまとわりつくような敵意を感じる。',
        'たくさんの巨大な円筒状のガラスが立ち並び、中には様々な人間が謎の液体に浮かぶ。もちろん肝心な部分は光の反射で見えない。こいつは…まさか…！培養プラントシーン表(PLST)を振ること。',
        'ＬＥＤが視覚的にやかましいコンピュータールーム。壁一面を埋めるディスプレイがちかちか光る。斜歯の誇る超コンピュータは性能に反して古めかしい。',
        '司令室。とうとうDr.斜歯を追い詰めた。泣いて土下座するDr.斜歯……の首がバネ仕掛けで飛び出し、大爆発。影武者だ！このシーン中のファンブル値は+2される。',
        '斜歯のロボット兵器がところ狭しと並べられている。こいつらが起動したとしたら…《潜伏術》で判定し、失敗した場合ロボット兵器に見つかって1点の射撃戦ダメージを受ける。',
        '自爆装置のある中枢ルーム。《火術》で判定し、成功すると自爆させることができる。自爆させた場合、Dr.斜歯に2点の接近戦ダメージを与えることができる。',
        '部屋に置かれた実験装置によりマインドコントロールを受けてしまう。このシーンのあなたはGMの指定した行動をとらねばならない。',
      ]
    ),
    'HM' => Table.new(
      '密室シーン表',
      '2D6',
      [
        '……ふう。あいつらと一緒にいると、緊張で息苦しくなる。トイレにいるときだけは、少しだけ落ち着くな。',
        'パチ、パチパチ……。電灯が明滅する。ずっと薄暗い部屋にいたせいで、時間の感覚が麻痺してきた。一体、いまは何時なんだ？',
        'ガチャン！誰かが食器を落として割ってしまったようだ。落としたヤツは悪びれもせず、こっちを見て肩をすくめている。',
        '誰かがつけたテレビ。くだらないバラエティ番組が映っている。静かな部屋に作り物の笑いがむなしく響く。',
        '空調がイカれているのか、妙に暑い。じっとりと汗ばんでくる……。',
        'ぴちょん、ぴちょん、ぴちょん……静かな室内に水道から水が滴る音が響く。さっき、きっちり閉めたはずなんだが。',
        'タバコの煙が目に染みる。閉じきった部屋で吸うから、空気が悪くなってきているな。',
        '床に散乱した書類の中から、一枚の写真を見つける。この部屋の持ち主と、その恋人らしき人物が仲よさそうに写っているが……。',
        '誰かが、八つ当たり気味に壁を殴る。そんなことして、一体なんになるというのだろう？',
        'ベッドでごろんと横になる。くそ！いつになったら、ここから出られるんだ！',
        '壁のシミをぼんやりとながめていたら、それがゆっくりと人の顔の形になり、にやりと笑いかけてきた。……幻覚か。',
      ]
    ),
    'HO' => Table.new(
      '病院シーン表',
      '2D6',
      [
        '謎の入院患者。車椅子に座った少女が、あなたをじっと見つめている。',
        '急患入り口。サイレンの音に続いて、ストレッチャーに乗せられた救急患者が運ばれてきた。',
        '病院の屋上。巨大な病院の敷地が一望できる。',
        '診察室。机と清潔なベットが設えられている無機室な部屋。机の上にはパソコンといくつかの器具が置かれている。',
        '病院の廊下。患者の姿はなく、静まり返っている。',
        '面会用のロビーは、入院患者とその見舞客で賑わっている。だが、それに紛れて、妙な気配を感じるが……。',
        '病室。きつい消毒液の香りに混じって、死の匂いが漂っている。',
        '奇妙な囁き声。「助けてくれ……。」そんな訴えを耳元で聞いた気がしたが……？',
        'ナースステーション。数人の看護師たちが慌ただしく業務をこなしている。',
        '中庭。どこからか悲鳴が聞こえたような気がするが……？',
        '霊安室。その扉が並ぶ長い廊下には、地下特有の淀んだ空気が漂っている。なぜだか気分が悪い。',
      ]
    ),
    'HR' => Table.new(
      '龍動シーン表',
      '2D6',
      [
        '血の匂いが辺りに充満している。何者かの戦いがあった気配。いや？まだ戦いは続いているのだろうか？',
        'これは……夢か？もう終わったはずの過去。しかし、それを忘れることはできない。',
        '眼下に広がる街並みを眺める。ここからなら街を一望できるが……。',
        '世界の終りのような暗闇。暗闇の中、お前たちは囁く。',
        '雰囲気のある古い街並みを歩く。あの建物は見たことがあるような……。',
        '霧の中を黒い影が飛び回っている。連中か？',
        '分厚い霧が街を折っている。霧の向こうには黒い影が……。',
        '強い雨が降り出す。人々は軒を求めて、大慌てで駆け出していく。',
        '大きな風が吹き荒ぶ。髪の毛や衣服が大きく揺れる。何かが起こりそうな予感……。',
        'どこからか奇妙な歌が響く。それはまるで、邪悪な神に捧げる祈りのようにも聞こえた。',
        '無残で冒涜的な死体。犠牲者の表情は苦悶に満ちあふれ、四肢には何者かに貪り食われた痕がある。',
      ]
    ),
    'HS' => Table.new(
      '催眠シーン表',
      '1D6',
      [
        'あなたは心地よいベッドの中で、恋人の肌のぬくもりを感じながら微睡んでいる。恋人は「そろそろ起きる時間」とベッドからすり抜ける。目を開けると、そこには裸のナビキャラクターがいた。そして、ナビキャラクターはあなたに優しく口づけをした。柔らかな感触が、あなたの記憶を掘り起こす。',
        'あなたは一人で死体の片付けを行っている。とても恐ろしく、とても憎かったナビキャラクターを殺したのだ。ナビキャラクターの意志のない瞳を見下ろし、あなたは晴れやかな気分になる。そして、その死体の手のひらに何かが書かれているのに気が付いた。',
        'あなたはなぜかTVショーに登場している。黒いサングラスをかけた司会者と楽しくおしゃべりしていたら、友人を紹介してほしいと言われ、電話を渡された。覚えのある番号にかけてみると、受話器の向こうからナビキャラクターの声がした。声は、あなたにこう囁く……。',
        'あなたはいつの間にか子どもになって、お気に入りのアニメを見ている。夢中になってアニメを見ていると、ナビキャラクターがアニメの登場人物として現れた。ナビキャラクターは、画面から抜け出してきて、あなたをアニメの世界に引きずり込む。そして、あなたは世界の真実に気付いてしまう！',
        'あなたはレストランでお腹を空かせている。そこに給仕の姿をしたナビキャラクターが、食事を運んできた。メインディッシュの銀製の蓋を開けてみると、そこにはあなたの大好物が。食欲をそそる香りが立ちこめ、あなたは重大な事実を思い出す。',
        'あなたは膨大な数の書架が林立する無人の図書館を歩いている。何気なく一冊の本を棚から抜き出すと、その本の向こう側にナビキャラクターの顔がのぞいている。「お前の求めるものは、その本の14ページに書かれている。」その言葉に従い、恐る恐る14ページを開いてみると……。',
      ]
    ),
    'HT' => Table.new(
      '滅びの塔シーン表',
      '2D6',
      [
        '血の臭いがあたりに充満している。何者かの戦いがあった気配。　いや？まだ戦いは続いているのだろうか？',
        'これは……夢か？　もう終わったはずの過去。しかし、それを忘れることはできない。',
        '眼下に広がる街並みを眺める。ここからなら街を一望できるが……。',
        '世界の終わりのような暗黒。暗闇の中、お前達は密やかに囁く。',
        '優しい時間が過ぎていく。影の世界のことを忘れてしまいそうだ。',
        '凄まじい業火。このシーンの登場する者は、『器術』分野からランダムに特技１つを選び、判定を行う。失敗すると射撃戦ダメージ1点を受ける。',
        '凄まじい人混み。喧噪。影の世界のことを知らない無邪気な人々の手柄話や無駄話が騒がしい。',
        '強い雨が降り出す。人々は、軒を求めて、大慌てて駆けだしていく。',
        '大きな風が吹き荒ぶ。髪の毛や衣服が大きく揺れる。何かが起こりそうな予感……',
        '凄まじい業火。このシーンの登場する者は、『器術』分野からランダムに特技１つを選び、判定を行う。失敗すると射撃戦ダメージ1点を受ける。',
        '太陽の微笑みがあなたを包み込む。影の世界の住人には、あまりにまぶしすぎる。',
      ]
    ),
    'HY' => Table.new(
      '夜行列車シーン表',
      '2D6',
      [
        '車内の灯りがすべて消える。停電か？それとも……。すべてが闇に覆われる。',
        'どうやらこの車輌は喫煙席のようだ。もうもうと煙がたちこめている。しかし、あなたたち以外に、客の姿は見えないのだが……？',
        '気分を変えるために、食堂車に移動する。そこには「解体屋」を名乗る例の女性がいた。あなたにむかって、婉然とほほえみかけてくる。',
        '……はッ！？夢か？いつの間にか眠っていたようだ。何か、悪夢を見ていたようなのだが……。',
        '窓越しに通過する駅のホームが見える。しかし、その駅の名前をどうしても読むことができない。どうにも、日本語には見えないのだが……。',
        'ガタンガタンガタン……路線を走る音をぼんやりと聞いている。一体、この列車はどこに向かっているんだろう？',
        '車内を照らす白熱灯に、羽虫がたかり、それに合わせるように光が明滅する。',
        '髑髏のような細身の車掌あなたのチケットを確認すると、にたりと邪悪に微笑み、去って行った。',
        '一等車輛はコンパートメントになっているようだ。コンパートメントの中からは、楽しげな親子の話し声が聞こえてくるが……？',
        '「お弁当に、お茶……。」車内販売の少女がやってくる。しかし、そこで売られている食べ物や飲み物は、生き物の内臓のような器官やぐねぐねと蠢く触手、異様な毛の塊など異形のものばかり。《経済力》の判定に成功すると、好きな「忍具」1つを購入できる。',
        '車輌の果てを確かめるため、延々扉をくぐっているが、いつまでたっても最前列（最後尾？）にたどりつかない。今、いったい何輌目だろうか？',
      ]
    ),
    'NTST' => Table.new(
      '夏の終わりシーン表',
      '2D6',
      [
        'どこから紛れ込んできたのか。ナタを持った少女がこちらに迫ってくる。あっそぼうよぉ。シーンに登場したキャラクターは《刀術》で判定し、失敗すると接近戦ダメージを1点受ける。',
        '暗い夜の森の中、月明かりのみが周囲を照らす。忍が動くにはいい時間だ。',
        '鬱蒼と繁っていて少し涼しい森の中。ほんのひとときでもいい。使命を忘れて少し涼もうか。',
        'ほとんど人が出入りしない公民館。かろうじて扇風機は回っているが暑い。',
        '山の斜面に立ち並ぶ墓石。踏み固められた周囲と墓前に供えられた小さな花束。こんな山中にも日々通う人がいるのだろうか。',
        '村の広場。田畑が一望できる。夏の風物詩であるセミの鳴き声がうるさい。',
        '澄み切った清流。冷たい飛沫が気持ちいい。森の中の穴場だ。',
        '神秘的な神社。夏の終わりに向けて祭りの準備がされているが、今は人がいないようだ。',
        '無人の廃屋が並び、不気味な雰囲気が漂う。廃屋の影から息を潜める何者かの気配を感じる。',
        '村の上空。ここから眺めれば村など小さいものだ。',
        'カツーン、カツーン、誰かが丑の刻参りをしている音が聞こえる。シーンに登場したキャラクターは《呪術》で判定し、成功すると誰かに《呪い》の変調を与えることができる。失敗すると《呪い》の変調を受ける。',
      ]
    ),
    'PLST' => Table.new(
      '培養プラントシーン表',
      '1D6',
      [
        '培養槽。あなたそっくりの人間が謎の液体に浸かっている。あなたは本当に本物のあなただろうか？《記憶術》で判定を行い、失敗すると《忘却》の変調を受ける。',
        '巨大なガラス管の中に冒涜的な生物が蠢く実験室。《意気》で判定を行い、失敗すると《マヒ》の変調を受ける。',
        '試験管に浮かぶDr斜歯のクローン脳が大量にあるクローン施設。',
        '各流派頭領が浮かぶ試験管。ランダムな特技を決定し判定を行う。決定した特技が自分の得意分野の場合、成功すると兵糧丸を１つ入手する。得意分野でない場合、失敗すると接近戦ダメージを1点受ける。',
        '無人の実験室。中央には破壊された培養器があり、人とも獣ともつかない濡れた足跡が扉へと続いている。',
        '美少年改造プラント。このシーンに登場した者は《変装術》で判定すること。成功した場合、美少年になることができる。',
      ]
    ),
    'FT' => Table.new(
      'ファンブル表',
      '1D6',
      [
        '何か調子がおかしい。そのサイクルの間、すべての行為判定にマイナス１の修正がつく。',
        'しまった！　好きな忍具を１つ失ってしまう。',
        '情報が漏れる！　このゲームであなたが獲得した【秘密】は、他のキャラクター全員の知るところとなる。',
        '油断した！　術の制御に失敗し、好きな【生命力】を１点失う。',
        '敵の陰謀か？　罠にかかり、ランダムに選んだ変調１つを受ける。変調は、変調表で決定すること。',
        'ふう。危ないところだった。特に何も起こらない。',
      ]
    ),
    'KFT' => Table.new(
      '怪ファンブル表',
      '1D6',
      [
        '何か調子がおかしい。そのサイクルの間、すべての行為判定にマイナス１の修正がつく。',
        'しまった！　好きな忍具を１つ失ってしまう。',
        '情報が漏れる！　あなた以外のキャラクターは、あなたの持っている【秘密】か【居所】の中から、好きなものをそれぞれ一つ知ることができる。',
        '油断した！　術の制御に失敗し、好きな【生命力】を１点失う。',
        '敵の陰謀か？　罠にかかり、ランダムに選んだ変調一つを受ける。変調は、変調表で決定すること。',
        'ふう。危ないところだった。特に何も起こらない。',
      ]
    ),
    'ET' => Table.new(
      '感情表',
      '1D6',
      [
        '共感（プラス）／不信（マイナス）',
        '友情（プラス）／怒り（マイナス）',
        '愛情（プラス）／妬み（マイナス）',
        '忠誠（プラス）／侮蔑（マイナス）',
        '憧憬（プラス）／劣等感（マイナス）',
        '狂信（プラス）／殺意（マイナス）',
      ]
    ),
    'WT' => Table.new(
      '変調表',
      '1D6',
      [
        '故障:すべての忍具が使用不能。１サイクルの終了時に、《絡繰術》で判定を行い、成功するとこの効果は無効化される。',
        'マヒ:修得済み特技がランダムに１つ使用不能になる。１サイクルの終了時に、《身体操術》で成功するとこの効果は無効化される。',
        '重傷:次の自分の手番に行動すると、ランダムな特技分野１つの【生命力】に１点ダメージ。１サイクルの終了時に、《生存術》で成功すると無効化される。',
        '行方不明:その戦闘終了後、メインフェイズ中に行動不可。１サイクルの終了時に、《経済力》で成功すると無効化される。',
        '忘却:修得済み感情がランダムに１つ使用不能。１サイクルの終了時に、《記憶術》で成功すると無効化される。',
        '呪い:修得済み忍法がランダムに１つ使用不能。１サイクルの終了時に、《呪術》で成功すると無効化される。',
      ]
    ),
    'KWT' => Table.new(
      '怪変調表',
      '1D6',
      [
        '故障:すべての忍具が使用不能になる。この効果は累積しない。各サイクルの終了時に、《絡繰術》で行為判定を行い、成功するとこの変調は無効化される。',
        'マヒ:修得している特技の中からランダムに一つを選び、その特技が使用不能になる。この効果は、修得している特技の数だけ累積する。各サイクルの終了時に、《身体操術l》で行為判定を行い、成功するとこの変調はすべて無効化される。',
        '重傷:命中判定、情報判定、感情判定を行うたびに、接近戦ダメージを１点受ける。この効果は累積しない。各サイクルの終了時に、《生存術》で行為判定を行い、成功するとこの変調は無効化される。',
        '行方不明:メインフェイズ中、自分以外がシーンプレイヤーのシーンに登場することができなくなる。この効果は累積しない。各サイクルの終了時に、《経済力》で行為判定を行い、成功するとこの変調は無効化される。',
        '忘却:修得している【感情】の中からランダムに一つを選び、その【感情】を持っていないものとして扱う。この効果は、修得している【感情】の数だけ累積する。各サイクルの終了時に、《記憶術》で行為判定を行い、成功するとこの変調はすべて無効化される。',
        '呪い:修得している忍法の中からランダムに一つを選び、その忍法を修得していないものとして扱う。この効果は、修得している忍法の数だけ累積する。各サイクルの終了時に、《呪術》で行為判定を行い、成功するとこの変調はすべて無効化される。',
      ]
    ),
    'GWT' => Table.new(
      '戦国変調表',
      '1D6',
      [
        '催眠:戦闘に参加した時、戦闘開始時、もしくはこの変調を受けた時に【生命力】を1点減少しないと、戦闘から脱落する。サイクル終了時に〈意気〉判定し成功すると無効化。',
        '火達磨:ファンブル値が1上昇し、ファンブル時に1点の近接ダメージを受ける。シーン終了時に無効化。',
        '猛毒:戦闘に参加した時、ラウンドの終了時にサイコロを1つ振る(飢餓と共用)。奇数だったら【生命力】を1減少。サイクル終了時に〈毒術〉判定し成功すると無効化。',
        '飢餓:戦闘に参加した時、ラウンドの終了時にサイコロを1つ振る(猛毒と共用)。偶数だったら【生命力】を1減少。サイクル終了時に〈兵糧術〉判定し成功すると無効化。',
        '残刃:回復判定、忍法、背景、忍具の効果による【生命力】回復無効。サイクル終了時に〈拷問術〉判定し成功すると無効化。',
        '野望:命中判定に+1、それ以外の判定に-1。サイクル終了時に〈憑依術〉判定し成功すると無効化。',
      ]
    ),
    'BT' => Table.new(
      '戦場表',
      '1D6',
      [
        '平地:特になし。',
        '水中:海や川や、プール、血の池地獄など。この戦場では、回避判定に-2の修正がつく。',
        '高所:ビルの谷間や樹上、断崖絶壁など。この戦場でファンブルすると1点のダメージを受ける。',
        '悪天候:嵐や吹雪、ミサイルの雨など。この戦場では、すべての攻撃忍法の間合が１上昇する。',
        '雑踏:人混みや教室、渋滞中の車道など。この戦場では、行為判定のとき、2D6の目がプロット値+1以下だとファンブルする。',
        '極地:宇宙や深海、溶岩、魔界など。ラウンドの終わりにＧＭが1D6を振り、経過ラウンド以下なら全員1点ダメージ。ここから脱落したものは変調表を適用する。',
      ]
    ),
  }.freeze

  # ランダム指定特技表
  RANDOM_SKILL_TABLE = [
    ['器術', ['絡繰術', '火術', '水術', '針術', '仕込み', '衣装術', '縄術', '登術', '拷問術', '壊器術', '掘削術']],
    ['体術', ['騎乗術', '砲術', '手裏剣術', '手練', '身体操術', '歩法', '走法', '飛術', '骨法術', '刀術', '怪力']],
    ['忍術', ['生存術', '潜伏術', '遁走術', '盗聴術', '腹話術', '隠形術', '変装術', '香術', '分身の術', '隠蔽術', '第六感']],
    ['謀術', ['医術', '毒術', '罠術', '調査術', '詐術', '対人術', '遊芸', '九ノ一の術', '傀儡の術', '流言の術', '経済力']],
    ['戦術', ['兵糧術', '鳥獣術', '野戦術', '地の利', '意気', '用兵術', '記憶術', '見敵術', '暗号術', '伝達術', '人脈']],
    ['妖術', ['異形化', '召喚術', '死霊術', '結界術', '封術', '言霊術', '幻術', '瞳術', '千里眼の術', '憑依術', '呪術']],
  ].freeze

  # 異形表
  METAMORPHOSE_TABLE = [
    '1D6を振り、「妖魔忍法表A」で、ランダムに忍法の種類を決定する。妖魔化している間、その妖魔忍法を修得しているものとして扱う。この異形は、違う種類の妖魔忍法である限り、違う異形として扱う。',
    '1D6を振り、「妖魔忍法表B」で、ランダムに忍法の種類を決定する。妖魔化している間、その妖魔忍法を修得しているものとして扱う。この異形は、違う種類の妖魔忍法である限り、違う異形として扱う。',
    '1D6を振り、「妖魔忍法表C」で、ランダムに忍法の種類を決定する。妖魔化している間、その妖魔忍法を修得しているものとして扱う。この異形は、違う種類の妖魔忍法である限り、違う異形として扱う。',
    '妖魔化している間、戦闘中、1ラウンドに使用できる忍法のコストが、自分のプロット値+3点になり、装備忍法の【揺音】を修得する。',
    '妖魔化している間、【接近戦攻撃】によって与える接近戦ダメージが2点になる。',
    '妖魔化している間、このキャラクターの攻撃に対する回避判定と、このキャラクターの奥義に対する奥義破り判定にマイナス1の修正がつく。'
  ].freeze

  # 妖魔忍法表A, B, C
  DEMON_SKILL_TABLES = [
    {
      :name => '妖魔忍法表A',
      :page => '(怪p.252)',
      :table => [
        '【震々】',
        '【神隠】',
        '【夜雀】',
        '【猟犬】',
        '【逢魔時】',
        '【狂骨】',
      ]
    },
    {
      :name => '妖魔忍法表B',
      :page => '(怪p.253)',
      :table => [
        '【野衾】',
        '【付喪神】',
        '【見越】',
        '【木魂】',
        '【鵺】',
        '【生剥】',
      ]
    },
    {
      :name => '妖魔忍法表C',
      :page => '(怪p.254)',
      :table => [
        '【百眼】',
        '【呑口】',
        '【荒吐】',
        '【怨霊】',
        '【鬼火】',
        '【蛭子】',
      ]
    }
  ].freeze

  setPrefixes(['MT', 'RTT'] + TABLES.keys)
end
