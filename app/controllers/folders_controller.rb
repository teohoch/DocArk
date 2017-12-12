class FoldersController < ApplicationController
  before_action :set_folder, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource

  # GET /folders
  # GET /folders.json
  def index
    folders = FolderDecorator.decorate_collection(Folder.is_owner(current_user.id).in_root)
    files = DocumentDecorator.decorate_collection(Document.is_owner(current_user.id).in_root)
    @contents = folders.map(&:to_simple_object) + files.map(&:to_simple_object)

    @current_folder = Folder.new(name: 'Root')
  end

  # GET /folders/1
  # GET /folders/1.json
  def show
    @user = User.find_by id: @folder.created_by
    @contents = @folder.decorate.contents
  end

  # GET /folders/new
  def new
    @folder = Folder.new(:parent_folder_id => (folder_new_params) )
    @fixed = params.has_key? :parent_folder_id
  end

  # GET /folders/1/edit
  def edit
  end

  # POST /folders
  # POST /folders.json
  def create
    @folder = Folder.new(name: folder_params[:name], parent_folder_id: folder_create_params, created_by: current_user, updated_by: current_user)

    respond_to do |format|
      if @folder.save
        format.html { redirect_to @folder, notice: "#{Folder.model_name.human} #{t('succesfully_created')}" }
        format.json { render :show, status: :created, location: @folder }
      else
        format.html { render :new }
        format.json { render json: @folder.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /folders/1
  # PATCH/PUT /folders/1.json
  def update
    respond_to do |format|
      if @folder.update(folder_params)
        format.html { redirect_to @folder, notice: "#{Folder.model_name.human} #{t('succesfully_updated')}" }
        format.json { render :show, status: :ok, location: @folder }
      else
        format.html { render :edit }
        format.json { render json: @folder.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /folders/1
  # DELETE /folders/1.json
  def destroy
    @folder.destroy
    respond_to do |format|
      format.html { redirect_to folders_url, notice: "#{Folder.model_name.human} #{t('succesfully_destroyed')}" }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_folder
      @folder = Folder.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def folder_params
      params.require(:folder).permit(:name, :parent_folder_id)
    end

    def folder_new_params
      if params.has_key?(:parent_folder_id) and params[:parent_folder_id] != '-1'
        (params[:parent_folder_id])
      else
        nil
      end
    end

    def folder_create_params
      if folder_params.has_key?(:parent_folder_id) and folder_params[:parent_folder_id] != '-1'
        (folder_params[:parent_folder_id])
      else
        nil
      end
    end
end
