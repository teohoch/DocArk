require 'pp'
module Api
  module V1
    class DocumentsController < APIController
      before_action :set_document, only: [:show, :update, :destroy]
      before_action :doorkeeper_authorize!
      respond_to :json

      def index
        query_documents = Document.all
        if document_params.has_key? :name
          query_documents = query_documents.name_ilike(document_params[:name].split(','))
        end
        if document_params.has_key? :parent_document_id
          parent_ids = document_params[:parent_folder_id].split(',').map{|x| x=='-1' ? nil : x}
          query_documents = query_documents.child_of(parent_ids)
        end
        if document_params.has_key? :limit
          query_documents = query_documents.limit(document_params[:limit])
        end
        if document_params.has_key? :offset
          query_documents = query_documents.offset(document_params[:offset])
        end
        @documents = DocumentDecorator.decorate_collection(query_documents)
      end

      def show
        @document = @document.decorate
      end

      def create
        if not document_create.has_key? :upfile
          error_renderer({code:400, message: 'No file provided!'})
        elsif (document_create[:upfile].size) > 5*(2.0**20)
          error_renderer({code:413, message: 'Uploaded File is too large, maximum size is 5 MB'})
        else
          name = (document_create.has_key?(:name) ? document_create[:name] : document_create[:upfile].original_filename)
          @document = Document.new(
              name: name,
              parent_folder_id: document_create[:parent_folder],
              created_by_id: 1,
              updated_by_id: 1
          )
          if @document.save
            @version = Version.new(
                                  document: @document,
                                  version: 1,
                                  size: (document_create[:upfile].size),
                                  current: true,
                                  upfile: document_create[:upfile],
                                  user: @document.created_by
            )
            if @version.save
              @document = @document.decorate
            else
              @document.destroy
              error_renderer(error_creator(@document.errors))
            end
          else
            error_renderer(error_creator(@document.errors))
          end
        end
      end

      def update
        if request.method_symbol == :put
          update_put
        elsif request.method_symbol == :patch
          update_patch
        else
          render partial: 'api/v1/error', locals: {:@error => {code: 501, message: 'Not Implemented'}}, status: 501
        end
      end

      def update_put
        old_version = @document.current_version
        @new_version = Version.new(
                              document: @document,
                              version: @document.version+1,
                              size: (document_create[:upfile].size/(2.0**20)).ceil,
                              current: true,
                              upfile: document_create[:upfile],
                              user: @document.created_by
        )
        if @new_version.save
          old_version.current = false
          old_version.save
          render :partial => 'api/v1/documents/document', locals: {document: Document.find(params[:id]).decorate}
        else
          error_renderer(error_creator(@document.errors))
        end
      end

      def update_patch
        if @document.update(:parent_folder => document_patch[:parent_folder])
          @document = @document.decorate
        else
          error_renderer(error_creator(@document.errors))
        end
      end

      def destroy
        if @document.destroy
          head :no_content
        else
          error_renderer(error_creator(@document.errors))
        end
      end

      private
      # Use callbacks to share common setup or constraints between actions.
      def set_document
        if Document.exists?(params[:id])
          @document = Document.find(params[:id])
        else
          render partial: 'api/v1/error', locals: {:@error => {code: 404, message: 'Document Not Found'}}, status: 404
        end
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def document_params
        temp = params.permit(:name, :id_parent_folder,:limit,:offset,:format)
        temp[:parent_folder_id] = temp.has_key? :id_parent_folder ? temp.delete(:id_parent_folder) : nil
        temp
      end

      def document_create
        temp = params.permit(:name, :id_parent_folder, :upfile)
        temp[:parent_folder] = nil
        if temp.has_key?(:id_parent_folder) and Folder.exists?(id: temp[:id_parent_folder])
          temp[:parent_folder] = Folder.find(temp[:id_parent_folder])
        end
        temp
      end

      def document_patch
        temp = params.permit(:id_parent_folder)
        temp[:parent_folder] = nil
        if temp.has_key?(:id_parent_folder) and Folder.exists?(id: temp[:id_parent_folder])
          temp[:parent_folder] = Folder.find(temp[:id_parent_folder])
        end
        temp
      end

      def force_delete_param
        temp = params.permit(:force)
        (temp.has_key? :force and temp[:force] == 1)
      end

    end
  end
end