class DocumentsController < ApplicationController
  def index
    @documents = current_user.documents.order(updated_at: :desc)
  end

  def show
    @document = current_user.documents.find(params[:id])
  end

  def create
    @document = current_user.documents.build(document_params)
    if @document.save
      redirect_back fallback_location: root_path, notice: "Document created."
    else
      redirect_back fallback_location: root_path, alert: "Failed to create document."
    end
  end

  def destroy
    current_user.documents.find(params[:id]).destroy
    redirect_back fallback_location: root_path, notice: "Document deleted."
  end

  private

  def document_params
    params.require(:document).permit(:title, :documentable_type, :documentable_id, :body, files: [])
  end
end
