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

  


end





      #Que devuelva todas las carpetas que tenga acceso el usuario
      #Creo dos carpetas para el usuario, y otras dos que no son del usuario
      #Luego hacer una llamada a la API: googlear api request rspec hago el request a get folders
      #Y eso me va a dar una respuestaÑ response, y va a tener un código, un body y un header
      #Lo primero que se revisa que el código sea 200, y la respuesta en code debe ser igual a 200
      #El body debe ser un arreglo json, ya que debe ser un arreglo de carpeta

      #El revisar que no esté la carpeta que no debería estar. Ese es otro test

      #-1 código para el root, para ver las carpetas del root.
      #/folders?Iparent=n° -^ context "with parent"
      #?name="wea" -^ context "with name"
      #?offset = 5
      #?limit = 5
      #?offset = 5 & limit =5





  #describe 'GET /folder/{id}' do
    #end