# frozen_string_literal: true

RSpec.describe 'image_edit.rb' do
  describe 'アジェンダ一覧画像生成' do
    before(:all) { @blob = ImageEdit.agenda_write('タイトル', '5分', '挨拶') }
    example('画像が生成された') { expect(@blob).not_to be_empty }
  end

  describe 'アジェンダ一覧画像生成' do
    before(:all) { @blob = ImageEdit.agenda_write('タイトル', '5分', '挨拶') }
    example('画像が生成された') { expect(@blob).not_to be_empty }
  end
end
