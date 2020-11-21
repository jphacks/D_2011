# frozen_string_literal: true

RSpec.describe 'image_edit.rb' do
  describe 'アジェンダ一覧画像生成' do
    before :all do
      @blob = agenda_write("タイトル", "5分", "挨拶")
      puts @blob
    end

    example('レスポンスがOKである') { expect(@blob).to be_ok }
  end
  
end
