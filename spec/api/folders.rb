require 'rspec'

RSpec.describe 'API Folder Resourse', type: :request do

  describe 'GET /folder' do
    context 'return all' do
      @folder_a = FactoryBot.create(:folder, has_children, family_tree: [{type:1},{type:1}])

      before { get '/api/v1/folders' }

      it 'should returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'should be a Json Array' do
        expect(json.parse(response.body)).not_to raise_error
        expect(response.contect_type).to eq("application/json")
      end

      it 'should contain 3' do
        #expect(response.count).to contain_exacly(3)
        expect(response.count).to eq(3)
      end
      it 'should contain all accesable folder' do
        accesable = Folder.all
        response_ids = response.map{ |a| a['id']}
        accesable.each do |folder|
          response_ids.should include folder.id
        end
      end
    end

    context 'return name of a folder' do
      @folder_a = FactoryBot.create(:folder, has_children, family_tree: [{type:1},{type:1}])

      before { get '/api/v1/folders' }

      it 'should returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'should be a Json Array' do
        expect(json.parse(response.body)).not_to raise_error
        expect(response.contect_type).to eq("application/json")
      end

      it 'should contain 2' do
        #expect(response.count).to contain_exacly(3)
        expect(response.count).to eq(2)
      end
      it 'should contain all accesable folder with name like ' do
        accesable = Folder.all
        response_ids = response.map{ |a| a['id']}
        accesable.each do |folder|
          response_ids.should include folder.id
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