# frozen_string_literal: true

RSpec.describe 'image_edit.rb' do
  describe 'アジェンダ一覧画像生成' do
    before(:all) { @blob = ImageEdit.agenda_write('タイトル', '5分', '挨拶') }
    example('正常に生成された') { expect(@blob).not_to be_empty }
  end

  describe 'トピック画像生成' do
    before(:all) { @blob = ImageEdit.topic_write('挨拶') }
    example('正常に生成された') { expect(@blob).not_to be_empty }
  end

  describe 'OGP画像生成' do
    before(:all) { @blob = ImageEdit.ogp_write('タイトル', '10:00') }
    example('正常に生成された') { expect(@blob).not_to be_empty }
  end
end
