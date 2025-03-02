require 'rails_helper'
require 'rspec_helper'

RSpec.describe "Merchant (of Item) endpoints", type: :request do
  
  before(:each) do
    Merchant.destroy_all
    @merchant1 = Merchant.create!(name: "Barbara")
    @merchant2 = Merchant.create!(name: "Mark")
    @merchant3 = Merchant.create!(name: "Jackson")
    @merchant4 = Merchant.create!(name: "Jason")
    
    Item.destroy_all
    @item1 = Item.create!(name: "Cat toy", description: "wiggling fish", unit_price: 0.34, merchant_id: @merchant1[:id])
    @item2 = Item.create!(name: "orange cream soda", description: "tasty and citrusy", unit_price: 3, merchant_id: @merchant2[:id])
    @item3 = Item.create!(name: "root beer", description: "smooth saspirilla", unit_price: 2, merchant_id: @merchant2[:id])
    @item4 = Item.create!(name: "can of ground peas", description: "mush", unit_price: 5, merchant_id: @merchant3[:id])
    @item5 = Item.create!(name: "cube", description: "not just any rectangular prism", unit_price: 8.00, merchant_id: @merchant4[:id])
    @item6 = Item.create!(name: "sphere", description: "now if only it were a cow", unit_price: 512.00, merchant_id: @merchant4[:id])
    # @item7 = Item.create!(name: "an unassuming book", description: "actually connects to Riven", unit_price: 1996.00, merchant_id: @merchant2[:id])   #For potential sad path logic
  end

  describe "#index tests" do
    it "happy path: returns merchant belonging to specified item (two examples)" do
      #Make an enumerable here to try both examples quickly (for kicks):
      testing_sequence = [[@item3, @merchant2], [@item4, @merchant3]]
      
      testing_sequence.each do |item, merchant|
        get "/api/v1/items/#{item.id}/merchant"
        response_data = JSON.parse(response.body, symbolize_names: true)
  
        expect(response).to be_successful
        expect(response_data[:data].length).to eq(3)
        expect(response_data[:data][:id]).to eq(merchant.id.to_s)
        expect(response_data[:data][:type]).to eq("merchant")
        expect(response_data[:data][:attributes][:name]).to eq(merchant.name)
      end
    end
    
    it "sad path: specified item does not exist" do
      nonexistant_id = 100000
      get "/api/v1/items/#{nonexistant_id}/merchant"
      error_message = JSON.parse(response.body, symbolize_names: true)

      expect(response).to_not be_successful
      expect(response.status).to eq(404)
      #Related: could I group some of these (DRY)?  I suspect so...
      expect(error_message[:message]).to eq("Your request could not be completed.")
      expect(error_message[:errors]).to be_a(Array)
      expect(error_message[:errors].first[:message]).to eq("Couldn't find Item with 'id'=#{nonexistant_id}")

    end

    xit "sad path: item has no associated merchant" do
      #NOTE: disabled test for now - probably not needed, may delete later (can also delete @item7 in this case).
      #This is harder to test; creating an item requires merchant_id, and DB protects against deleting associated merchant

      # get "/api/v1/items/#{@item7.id}/merchant"

      # expect(response).to_not be_successful
      # expect(response.status).to eq(404)
      # #Related: could I group some of these (DRY)?  I suspect so...
      # expect(error_message[:message]).to eq("Your request could not be completed.")
      # expect(error_message[:errors]).to be_a(Array)
      # expect(error_message[:errors].first[:message]).to eq("Couldn't find Merchant with 'id'=#{nonexistant_id}")
    end
  end

end
