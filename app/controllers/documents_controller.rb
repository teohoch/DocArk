class DocumentsController < ApplicationController
  before_action :set_document, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource

  # GET /documents
  # GET /documents.json
  def index
    @documents = Document.is_owner(current_user.id)
  end

  # GET /documents/1
  # GET /documents/1.json
  def show
  end

  # GET /documents/new
  def new
    @document = Document.new(:parent_folder_id => (folder_new_params) )
    @fixed = params.has_key? :parent_folder_id
  end

  # GET /documents/1/edit
  def edit
  end

  # GET /documents/1/upgrade
  def upgrade
  end

  # POST /documents
  # POST /documents.json
  def create


    if not document_create.has_key? :upfile
      @document.errors.add(:upfile, t('document.error.upfile.missing'))
      @fixed = true
      render :new
    elsif (document_create[:upfile].size) > 1024*(2.0**20)
      @document.errors.add(:upfile, t('document.error.upfile.size'))
      @fixed = true
      render :new
    else
      name = (document_create[:name].blank? ? document_create[:upfile].original_filename : document_create[:name])
      @document = Document.new(name: name,
                               parent_folder_id: folder_create_params,
                               created_by: current_user,
                               updated_by: current_user)
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
          redirect_to @document, notice: "#{Document.model_name.human} #{t('succesfully_created')}"
        else
          @document.destroy
          @document = Document.new(name: document_params[:name],
                                   parent_folder_id: folder_create_params,
                                   created_by: current_user,
                                   updated_by: current_user)
          @document.errors[:base] << t('document.error.base')
          @fixed = true
          render :new
        end
      else
        @fixed = true
        render :new
      end
    end

  end

  # PATCH/PUT /documents/1
  # PATCH/PUT /documents/1.json
  def update
    if request.request_method_symbol == :put
      update_put
    elsif request.request_method_symbol == :patch
      update_patch
    else
      render partial: 'api/v1/error', locals: {:@error => {code: 501, message: 'Not Implemented'}}, status: 501
    end


=begin
    respond_to do |format|
      if @document.update(document_params)
        format.html { redirect_to @document, notice: 'Document was successfully updated.' }
        format.json { render :show, status: :ok, location: @document }
      else
        format.html { render :edit }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
=end
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
      redirect_to @document, notice: "#{t('new_f')} #{Version.model_name.human} #{t('succesfully_uploaded')}"
    else
      @document.errors.add(:upfile, @new_version.errors[:upfile][0])
      render :upgrade
    end
  end

  def update_patch
    if @document.update(:parent_folder_id => document_patch[:parent_folder_id])
      redirect_to @document, notice: "#{Document.model_name.human} #{t('succesfully_updated')}"
    else
      error_renderer(error_creator(@document.errors))
    end
  end


  # DELETE /documents/1
  # DELETE /documents/1.json
  def destroy
    @document.destroy
    respond_to do |format|
      format.html { redirect_to documents_url, notice: "#{Document.model_name.human} #{t('succesfully_destroyed')}" }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_document
      @document = Document.find(params[:id])
      if params.has_key? :version and @document.available_versions.include?(params[:version].to_i)
        @document.version = params[:version].to_i
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def document_params
      params.require(:document).permit(:name, :parent_folder_id)
    end

    def folder_new_params
      if params.has_key?(:parent_folder_id) and params[:parent_folder_id] != '-1'
        (params[:parent_folder_id])
      else
        nil
      end
    end

    def folder_create_params
      if document_params.has_key?(:parent_folder_id) and document_params[:parent_folder_id] != '-1'
        (document_params[:parent_folder_id])
      else
        nil
      end
    end

    def document_create
      temp = params.require(:document).permit(:name, :parent_folder_id, :upfile)
      temp[:parent_folder] = nil
      if temp.has_key?(:parent_folder_id) and Folder.exists?(id: temp[:parent_folder_id])
        temp[:parent_folder] = Folder.find(temp[:parent_folder_id])
      end
      temp
    end

  def document_patch
    params.permit(:parent_folder_id)
  end
end
