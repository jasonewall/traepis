class BuildsController < ApplicationController
  before_action :find_build, only: [:show, :update, :destroy]

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

  def update
    @build.image_tag = params.require(:build)[:image_tag]

    if builds_repository.save(@build)
      flash[:notice] = t('.success')
      redirect_to build_path(@build)
    else
      flash.now[:errors] = builds_repository.errors.full_messages
      render :show
    end
  end

  def destroy
    if builds_repository.destroy(@build)
      redirect_to builds_path
    end
  end

private

  def find_build
    @build = builds_repository.find(params[:id])
  end
end
