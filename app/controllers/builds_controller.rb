class BuildsController < ApplicationController
  def index
    @builds = builds_repository.all
  end

  def create
    @build = Build.new(params.require(:build).permit(:image_tag, :id))

    if builds_repository.save(@build)
      redirect_to builds_path
    else
      flash.now[:errors] = builds_repository.errors.full_messages
      render :index
    end
  end

  def show
    @build = builds_repository.find(params[:id])
  end
end
