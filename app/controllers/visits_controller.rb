class VisitsController < ApplicationController
  before_action :find_visit, only: [:show, :edit, :update, :destroy]
  before_action :ensure_current_user_is_visitor, only: [:show, :edit, :update, :destroy]

  def new
    @visit ||= Visit.new(user_id: params[:user_id], start_date: '2017-04-28', end_date: '2017-04-29')
  end

  def create
    @visit = Visit.new(visit_params)
    @visit.user_id = current_user.id

    if @visit.save
      redirect_to visit_url(@visit), notice: "Visit created!"
    else
      flash.now[:errors] = @visit.errors.full_messages
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
  end

  def update
    if @visit.update(visit_params)
      redirect_to visit_url(@visit), notice: "Visit updated"
    else
      flash.now[:errors] = @visit.errors.full_messages
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @visit.destroy
      redirect_to user_url(current_user), notice: "Visit canceled"
    else
      flash.now[:errors] = @visit.errors.full_messages
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def visit_params
    params
      .require(:visit)
      .permit(:zipcode, :num_travelers, :start_date, :end_date)
  end

  def find_visit
    @visit = Visit.find_by_id(params[:id])
    if @visit.nil?
      flash[:notice] = "Oops! That visit has been canceled."
      redirect_to user_url(current_user)
    end
  end

  def ensure_current_user_is_visitor
    redirect_to user_url(current_user) unless @visit.user_id == current_user.id
  end
end
