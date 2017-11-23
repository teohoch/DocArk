require 'rails_helper'

RSpec.describe 'API Folder Resourse', type: :request do

  describe 'GET /folder' do
    context 'return all' do
      before(:each) do
        FactoryBot.create(:folder, :has_children, name: 'cala', family_tree: [{name: 'lala',type:1},{type:1}])
        get '/api/v1/folders'
      end

      it 'should returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'should be a Json Array' do
        expect{JSON.parse(response.body)}.not_to raise_error
        expect(response.content_type).to eq("application/json")
      end

      it 'should contain 3' do
        #expect(response.count).to contain_exacly(3)
        expect(JSON.parse(response.body).count).to eq(3)
      end
      it 'should contain all accesable folder' do
        accesable = Folder.all
        response_ids = JSON.parse(response.body).map{ |a| a['id']}
        accesable.each do |folder|
          expect(response_ids).to include(folder.id)
        end
      end
    end

    context 'return name of a folder' do
      before(:each) do
        FactoryBot.create(:folder, :has_children, name: 'cala', family_tree: [{name: 'lala',type:1},{type:1}])
        get '/api/v1/folders?name=la'
      end

      it 'should returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'should be a Json Array' do
        expect{JSON.parse(response.body)}.not_to raise_error
        expect(response.content_type).to eq("application/json")
      end

      it 'should contain 2' do
        #expect(response.count).to contain_exacly(3)
        expect(JSON.parse(response.body).count).to eq(2)
      end
      it 'should contain all accesable folder with name like ' do
        accesable = Folder.name_ilike(['la'])
        response_ids = JSON.parse(response.body).map{ |a| a['id']}
        accesable.each do |folder|
          expect(response_ids).to include(folder.id)
        end
      end
    end

    context 'return folders that are children of the ID' do
      before(:each) do
        @father = FactoryBot.create(:folder, :has_children, name: 'padre', family_tree: [{type:1},{type:1},{type:1},{type:1}])
        get "/api/v1/folders?id_parent_folder =#{@father.id}"
      end

      it 'should returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'should be a Json Array' do
        expect{JSON.parse(response.body)}.not_to raise_error
        expect(response.content_type).to eq("application/json")
      end

      it 'should contain 4' do
        #expect(response.count).to contain_exacly(3)
        expect(JSON.parse(response.body).count).to eq(4)
      end
      it 'should contain all accesable children folders of the ID father ' do
        accesable = Folder.child_of([@father.id])
        response_ids = JSON.parse(response.body).map{ |a| a['id']}
        accesable.each do |folder|
          expect(response_ids).to include(folder.id)
        end
      end
    end

    context 'return a limit number of folders' do
      before(:each) do
        @father = FactoryBot.create(:folder, :has_children, family_tree: [{type:1},{type:1},{type:1},{type:1}])
        get "/api/v1/folders?limit =2"
      end

      it 'should returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'should be a Json Array' do
        expect{JSON.parse(response.body)}.not_to raise_error
        expect(response.content_type).to eq("application/json")
      end

      it 'should contain 2' do
        #expect(response.count).to contain_exacly(2)
        expect(JSON.parse(response.body).count).to eq(2)
      end
      it 'should show a limit of folders' do
        accesable = Folder.limit(2)
        response_ids = JSON.parse(response.body).map{ |a| a['id']}
        accesable.each do |folder|
          expect(response_ids).to include(folder.id)
        end
      end
    end

    context 'return the remaining folder from the offset' do
      before(:each) do
        @father = FactoryBot.create(:folder, :has_children, family_tree: [{type:1},{type:1},{type:1},{type:1}])
        get "/api/v1/folders?offset =3"
      end

      it 'should returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'should be a Json Array' do
        expect{JSON.parse(response.body)}.not_to raise_error
        expect(response.content_type).to eq("application/json")
      end

      it 'should contain 2' do
        #expect(response.count).to contain_exacly(2)
        expect(JSON.parse(response.body).count).to eq(2)
      end
      it 'should show a limit of folders' do
        accesable = Folder.offset(3)
        response_ids = JSON.parse(response.body).map{ |a| a['id']}
        accesable.each do |folder|
          expect(response_ids).to include(folder.id)
        end
      end
    end
  end

  describe 'GET/folder{id}' do
    context 'return an existing folder' do
      before(:each) do
        @test = FactoryBot.create(:folder)
        get "/api/v1/folders/#{test.id}"
      end

      it 'should returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'should be a Json Array' do
        expect{JSON.parse(response.body)}.not_to raise_error
        expect(response.content_type).to eq("application/json")
      end

      it 'should contain 1' do
        #expect(response.count).to contain_exacly(1)
        expect(JSON.parse(response.body).count).to eq(1)
      end
      it 'should contain the searched folder' do
        response_id = JSON.parse(response.body)[:id]
        expect(response_id).to eq(@test.id)
        end
      end
    context 'return an non-existing folder' do
      before(:each) do
        #FactoryBot.create(:folder, :has_children, family_tree: [{type:1},{type:1}])
        get '/api/v1/folders/909'
      end

      it 'should returns status code 404' do
        expect(response).to have_http_status(404)
      end

      #it 'returns a not found message' do
       # expect(response.body).to match(/Couldn't find The Folder/)
      #end

      it 'should be error 404' do
        response_error = JSON.parse(response.body)
        response_error['code'].to eq(404)
      end

    end
  end

  describe 'POST/folder{id}' do
    context 'create a folder with a name' do
      before(:each) do
        post "/api/v1/folders/", params: {name: 'lala'}
      end

      it 'should returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'should be a Json Array' do
        expect{JSON.parse(response.body)}.not_to raise_error
        expect(response.content_type).to eq("application/json")
      end

      it 'should be in the DB' do
        @carpeta = Folder.where(name: lala).first
        expect(JSON.parse(response.body)['id']).to eq(@carpeta.id)
      end

    end

    context 'create a folder with a name and an ID father' do
      before(:each) do
        @parent_folder = FactoryBot.create(:folder)

        post "/api/v1/folders/", params: {name: 'lala', id_parent_folder: @parent_folder.id}
      end

      it 'should returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'should be a Json Object' do
        expect{JSON.parse(response.body)}.not_to raise_error
        expect(response.content_type).to eq("application/json")
      end

      it 'should be in the DB' do
        @carpeta= Folder.where(name: lala)
        JSON.parse(response.body)['id'].to eq(@carpeta)
      end

      it 'should contain the searched folder' do
        response_id = JSON.parse(response.body)[:id]
        expect(response_id).to eq(@parent_folder.id)
      end

      it 'should be in the DB' do
        @c = Folder.where(name: 'lala').first
        expect(c.parent_folder_id).to eq(@parent_folder.id)
      end

    end

  end
end
