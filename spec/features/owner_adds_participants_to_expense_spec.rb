require 'rails_helper'

feature 'owner adds participants to expense' do
  scenario 'sucessfully' do
    owner = create(:user)
    user = create(:user)
    expense = create(:expense, title: 'Futebol de domingo')
    expense.user_expenses.create(user: owner, payment_status: :open,
                                 role: :owner)

    login_as(user, scope: :user)
    visit "/convites/#{expense.token}"
    click_on 'Aceitar convite'

    expect(page).to have_css('h1', text: 'Futebol de domingo')
    expect(page).to have_css('h2', text: 'Participantes')
    expect(page).to have_css('td', text: user.name)
  end

  scenario 'and participants is not registered' do
    owner = create(:user)
    expense = create(:expense, title: 'Futebol de domingo')
    expense.user_expenses.create(user: owner, payment_status: :open,
                                 role: :owner)

    visit "/convites/#{expense.token}"

    expect(current_path).to eq(new_user_session_path)
  end

  scenario 'and participant already is in expense' do
    user = create(:user)
    owner = create(:user)
    expense = create(:expense, title: 'Futebol de domingo')
    expense.user_expenses.create(user: user, payment_status: :open,
                                 role: :participant)
    expense.user_expenses.create(user: owner, payment_status: :open,
                                 role: :owner)

    login_as(user, scope: :user)
    visit "/convites/#{expense.token}"

    expect(current_path).to eq expense_path(expense)
    expect(page).to have_css('.alert-info', text: 'Você já está nesse rateio')
  end
end
