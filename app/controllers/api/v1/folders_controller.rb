require 'pp'
module Api
  module V1
    class FoldersController < APIController

      before_action only: [:index, :show] do
        doorkeeper_authorize! :read
      end

      before_action only: [:create, :update] do
        doorkeeper_authorize! :write
      end

      before_action only: [:destroy] do
        doorkeeper_authorize! :delete
      end
      before_action :set_folder, only: [:show, :update, :destroy]

      respond_to :json

      def index
        query_folders = Folder.is_owner(current_user.id)
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
        if not folder_create.has_key?(:name)
          error_renderer({code: 400, message: 'Name parameter is missing'})
        else
          @folder = Folder.new(folder_create.merge({:created_by_id => 1,:updated_by_id => 1}))
          if @folder.save
            @folder = @folder.decorate
          else
            error_renderer(error_creator(@folder.errors))
          end
        end
      end

      def update
        if @folder.update(folder_create)
          @folder = @folder.decorate
        else
          error_renderer(error_creator(@folder.errors))
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
          error_renderer(error_creator(@folder.errors))
        end
      end

      private
      # Use callbacks to share common setup or constraints between actions.
      def set_folder
        if Folder.exists?(params[:id])
          @folder = Folder.find(params[:id])
          unless current_user.id == @folder.created_by_id
            error_renderer({code: 401, message: 'Unauthorized'})
          end
        else
          error_renderer({code: 404, message: 'Folder Not Found'})
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

    end
  end
end