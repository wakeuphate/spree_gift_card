Spree::OrdersController.class_eval do

  def update_with_gift_code
    @order = current_order
    @order.update_attributes(params[:order])

    if @order.gift_code.present?
      if apply_gift_code
        @order.line_items = @order.line_items.select {|li| li.quantity > 0 }
        fire_event('spree.order.contents_changed')
      else
        params[:order][:gift_code] = nil
        @order.gift_code = nil
        render :edit and return
      end
    end

    update_without_gift_code
  end

  alias_method_chain :update, :gift_code

end
