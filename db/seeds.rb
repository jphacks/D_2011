if RespondWord.count == 0
  RespondWord.create([
    {word: 'アイデアソン'},
    {word: '反省会'},
    {word: '定例'},
  ])
end

if RespondContent.count == 0
  RespondContent.create([
    {
      respond_words_id: 0,
      content: '事前案内・解説',
      duration: 1200,
    },
    {
      respond_words_id: 0,
      content: 'アイデア出し',
      duration: 1800,
    },
    {
      respond_words_id: 0,
      content: '発表',
      duration: 600,
    },
    {
      respond_words_id: 1,
      content: '問題の共有',
      duration: 1200,
    },
    {
      respond_words_id: 1,
      content: '原因の分析',
      duration: 1800,
    },
    {
      respond_words_id: 1,
      content: '今後の方針',
      duration: 900,
    },
    {
      respond_words_id: 2,
      content: '実施事項の共有',
      duration: 600,
    },
    {
      respond_words_id: 2,
      content: '今後すること',
      duration: 600,
    },
    {
      respond_words_id: 2,
      content: 'まとめ',
      duration: 600,
    }
  ])
end