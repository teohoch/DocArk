require 'pp'
module Api
  module V1
    class DocumentsController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :set_document, only: [:show, :update, :destroy]
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
      end

      def create
        render partial: 'api/v1/error', locals: {:@error => {code: 501, message: 'Not Implemented'}}, status: 501
      end

      def update
        unless @document.update(document_create)
          a = error_creator(@document.errors)
          render partial: 'api/v1/error', locals: {:@error => a}, status: a[:code]
        end
      end

      def destroy
        if @document.destroy
          head :no_content
        else
          a = error_creator(@document.errors)
          render partial: 'api/v1/error', locals: {:@error => a}, status: a[:code]
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
        if temp.has_key? :id_parent_folder
          temp[:parent_folder_id] = temp.delete(:id_parent_folder)
        end
        temp
      end
      def document_create
        temp = params.permit(:name, :id_parent_folder)
        if temp.has_key? :id_parent_folder
          temp[:parent_folder_id] = temp.delete(:id_parent_folder)
        end
        temp
      end
      def force_delete_param
        temp = params.permit(:force)
        (temp.has_key? :force and temp[:force] == 1)
      end
      def error_creator(error_info)
        case error_info.keys[0]
          when :parent_folder
            {code: 400, message: 'The Parent Folder must be valid.'}
          when :name
            {code: 409, message: 'Conflict - Duplicated Name in the folder.'}
          when :parent_folder_ownership
            {code: 401, message: 'You don\'t have access to the parent folder.'}
          else
            {code: 500, message: 'Unknown Error'}
        end
      end
    end
  end
end