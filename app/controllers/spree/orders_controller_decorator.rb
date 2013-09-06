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

    update
  end

  def update
      @order = current_order
      unless @order
        flash[:error] = t(:order_not_found)
        redirect_to root_path and return
      end

      if @order.update_attributes(params[:order])
        @order.line_items = @order.line_items.select {|li| li.quantity > 0 }
        fire_event('spree.order.contents_changed')
        respond_with(@order) do |format|
          format.html do
            if params.has_key?(:checkout)
              @order.next_transition.run_callbacks if @order.cart?
              redirect_to checkout_state_path(@order.checkout_steps.first)
            else
              redirect_to checkout_state_path(@order.state)
            end
          end
        end
      else
        respond_with(@order)
      end
    end


end
