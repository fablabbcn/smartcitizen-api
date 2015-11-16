require 'rails_helper'

describe V0::TagsController do

  let(:application) { create :application }
  let(:user) { create :user }
  let(:admin) { create :admin }
  let(:token) { create :access_token, application: application, resource_owner_id: user.id }
  let(:admin_token) { create :access_token, application: application, resource_owner_id: admin.id }
  let(:tag) { create :tag }

  it "needs general user tests"

  describe "GET /tags/<id>" do
    it "returns a tag" do
      tag = create(:tag)
      j = api_get "tags/#{tag.id}"
      expect(j['id']).to eq(tag.id)
      expect(response.status).to eq(200)
    end
  end

  describe "GET /tags" do
    it "returns all the tags" do
      first = create(:tag)
      second = create(:tag)
      j = api_get 'tags'
      expect(j.length).to eq(2)
      expect(j.map{|m| m['id']}).to eq([first.id, second.id])
      expect(response.status).to eq(200)
      expect(response.headers.keys).to include('Total')
    end
  end

  describe "POST /tags" do

    describe "admin" do

      it "creates a tag" do
        j = api_post 'tags', {
          name: 'new tag',
          description: 'blah blah blah',
          unit: 'm',
          access_token: admin_token.token
        }
        expect(j['name']).to eq('new tag')
        expect(response.status).to eq(201)
      end

      it "does not create a tag with missing parameters" do
        j = api_post 'tags', {
          name: nil,
          access_token: admin_token.token
        }
        expect(j['id']).to eq('unprocessable_entity')
        expect(response.status).to eq(422)
      end

    end

  end

  describe "PUT /tags/:id" do

    let!(:tag) { create :tag }

    it "updates a tag" do
      j = api_put "tags/#{tag.id}", { name: 'new name', access_token: admin_token.token }
      expect(j['name']).to eq('new name')
      expect(response.status).to eq(200)
    end

    it "does not update a tag with invalid access_token" do
      j = api_put "tags/#{tag.id}", { name: 'new name', access_token: '123' }
      expect(j['id']).to eq('forbidden')
      expect(response.status).to eq(403)
    end

    it "does not update a tag with missing access_token" do
      j = api_put "tags/#{tag.id}", { name: 'new name', access_token: nil }
      expect(j['id']).to eq('forbidden')
      expect(response.status).to eq(403)
    end

    it "does not update a tag with empty parameters access_token" do
      j = api_put "tags/#{tag.id}", { name: nil, access_token: admin_token.token }
      expect(j['id']).to eq('unprocessable_entity')
      expect(response.status).to eq(422)
    end

  end


  describe "DELETE /tags/:id" do

    it "deletes a tag" do
      api_delete "tags/#{tag.id}", { access_token: admin_token.token }
      expect(response.status).to eq(200)
    end

    it "does not delete a tag with invalid access_token" do
      api_delete "tags/#{tag.id}"
      expect(response.status).to eq(403), { access_token: '123' }
    end

    it "does not delete a tag with missing access_token" do
      api_delete "tags/#{tag.id}"
      expect(response.status).to eq(403)
    end

  end
end
