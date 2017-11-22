require 'pp'
module Api
  module V1
    class FoldersController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :set_folder, only: [:show, :update, :destroy]
      respond_to :json

      def index
        query_folders = Folder.all
        if folder_params.has_key? :name
          query_folders = query_folders.name_ilike(folder_params[:name].split(','))
        end
        if folder_params.has_key? :parent_folder_id
          parent_ids = folder_params[:parent_folder_id].split(',').map{|x| x=='-1' ? nil : x}
          query_folders = query_folders.child_of(parent_ids)
        end
        if folder_params.has_key? :limit
          query_folders = query_folders.limit(folder_params[:limit])
        end
        if folder_params.has_key? :offset
          query_folders = query_folders.offset(folder_params[:offset])
        end
        @folders = FolderDecorator.decorate_collection(query_folders)
      end

      def show
        @folder = @folder.decorate
      end

      def create
        @folder = Folder.new(folder_create.merge({:created_by_id => 1,:updated_by_id => 1}))
        if @folder.save
          @folder.decorate
        else
          a = error_creator(@folder.errors)
          render partial: 'api/v1/error', locals: {:@error => a}, status: a[:code]
        end
      end

      def update
        if @folder.update(folder_create)
          @folder = @folder.decorate
        else
          a = error_creator(@folder.errors)
          render partial: 'api/v1/error', locals: {:@error => a}, status: a[:code]
        end
      end

      def destroy
        if force_delete_param
          @folder.documents.destroy_all
          @folder.folders.each(&:force_delete)
        end

        if @folder.destroy
          head :no_content
        else
          a = error_creator(@folder.errors)
          render partial: 'api/v1/error', locals: {:@error => a}, status: a[:code]
        end
      end

      private
      # Use callbacks to share common setup or constraints between actions.
      def set_folder
        if Folder.exists?(params[:id])
          @folder = Folder.find(params[:id])
        else
          render partial: 'api/v1/error', locals: {:@error => {code: 404, message: 'Folder Not Found'}}, status: 404
        end
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def folder_params
        temp = params.permit(:name, :id_parent_folder,:limit,:offset,:format)
        if temp.has_key? :id_parent_folder
          temp[:parent_folder_id] = temp.delete(:id_parent_folder)
        end
        temp
      end
      def folder_create
        temp = params.permit(:name, :id_parent_folder)
        temp[:parent_folder_id] = temp.delete(:id_parent_folder)
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
          when :contents
            {code: 403, message: 'The Folder you\'re trying to delete has contents!.'}
          else
            {code: 500, message: 'Unknown Error'}
        end
      end
    end
  end
end