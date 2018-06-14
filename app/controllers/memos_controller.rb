class MemosController < ApplicationController
  def create
    @memo = Memo.create
    authorize @memo
  end

  # def edit
  # # this method will have to be deleted since we will display the form directly
  # # inside of the fans view
  #   @memo = Memo.find(params[:id])
  #   authorize @memo
  # end

  def update
    @memo = Memo.find(params[:id])
    authorize @memo
    @memo.update(memo_params)
    @fan = Fan.find(params[:id])
    redirect_to fan_path(@fan)
    authorize @fan
  end

  private

  def memo_params
    params.require(:memo).permit(:content)
  end
end
