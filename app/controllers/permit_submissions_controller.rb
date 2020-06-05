class PermitSubmissionsController < ActionController::Base
  before_action :authenticate_user!

  layout 'application'

  def index
    sort_by = permit_index_params.fetch(:sort_by, nil)
    if sort_by
      @permits = current_user.permit_submissions.order(sort_by)
    else
      @permits = current_user.permit_submissions
    end
  end

  def destroy
    current_user.permit_submissions.find(params.fetch(:id)).destroy!
    redirect_to permit_submissions_path
  end

  def show
    @permit = current_user.permit_submissions.find(params.fetch(:id))
  end

  def create
    @permit = PermitSubmission.new(permit_params)
    if @permit.save!
      @permit_document = @permit.permit_documents.create!
      @permit_document.document.attach(permit_document_params)
      @permit_document.save!
      redirect_to permit_submissions_path, flash: { success: 'You saved your permit' }
    else
      render :new, flash: { error: 'Could not save' }
    end
  end

  def new
    @permit = current_user.permit_submissions.build
  end

  private

  def permit_index_params
    params.permit(:sort_by)
  end

  def permit_params
    params.require(:permit).permit(:name, :agency, :deadline, :status).merge(user_id: current_user.id)
  end

  def permit_document_params
    params.fetch(:permit_documents, {}).permit(:document, {}).fetch(:document, nil)
  end
end
