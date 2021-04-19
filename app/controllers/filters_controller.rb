class FiltersController < ApplicationController
  before_action :authenticate_user!

  def index
    @filters = current_account.filters
  end

  def new
    @filter = current_account.filters.build
  end

  def create
    filter_params = params.require(:filter).permit(:name, :sql)
    @filter = current_account.filters.build(filter_params)

    if @filter.save
      redirect_to edit_filter_path(@filter)
    else
      render :new
    end
  end

  def edit
    @filter = current_account.filters.find(params[:id])
    @example_code_files = current_account.code_files.where(@filter.sql).limit(10)
  end

  def update
    @filter = current_account.filters.find(params[:id])
    filter_params = params.require(:filter).permit(:name, :sql)

    if @filter.update(filter_params)
      redirect_to edit_filter_path(@filter)
    else
      @example_code_files = current_account.code_files.where(@filter.sql).limit(10)
      render :edit
    end
  end
end
