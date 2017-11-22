require 'rspec'

RSpec.describe 'API Folder Resourse', type: :request do

  describe 'GET /folder' do
    context 'return all' do
      @folder_a = FactoryBot.create(:folder, has_children, family_tree: [{type:1},{type:1}])
      before { get '/api/v1/folders' }

      it 'should returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'should be a Json Array'
      it 'should contain 3'
      it 'should contain all accesable folder' do
        accesable = Folder.all
        response_ids = response.map{ |a| a['id']}
        accesable.each do |folder|
          response_ids.should include folder.id
        end
      end
    end
  end
end
