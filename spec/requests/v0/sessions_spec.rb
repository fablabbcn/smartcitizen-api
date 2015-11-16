require 'rails_helper'

describe V0::SessionsController do

  let!(:user) { create(:user, username: 'milhouse', password: 'greatpass') }

  it "works with legacy password"

  it "gets access_token with valid parameters" do
    j = api_post 'sessions', { username: 'milhouse', password: 'greatpass'}
    token = user.access_token.token
    expect(j['access_token']).to eq(user.access_token.token)

    # make sure it doesn't change
    j = api_post 'sessions', { username: 'milhouse', password: 'greatpass'}
    expect(j['access_token']).to eq(token)
  end

  it "doesn't get access_token with incorrect password" do
    j = api_post 'sessions', { username: 'milhouse', password: 'incorrect'}
    expect(j['id']).to eq('unprocessable_entity')
    expect(j['errors']['password'].to_s).to include('incorrect')
    expect(response.status).to eq(422)
  end

  it "doesn't get access_token with missing password" do
    j = api_post 'sessions', { username: 'milhouse'}
    expect(j['id']).to eq('parameter_missing')
    expect(response.status).to eq(400)
  end

  it "doesn't get access_token with missing username" do
    j = api_post 'sessions', { password: 'greatpass'}
    expect(j['id']).to eq('parameter_missing')
    expect(response.status).to eq(400)
  end

  it "doesn't get access_token with nonexistent user" do
    j = api_post 'sessions', { username: 'bart', password: 'greatpass' }
    expect(j['id']).to eq('record_not_found')
    expect(response.status).to eq(404)
  end

end
