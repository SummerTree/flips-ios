Scenario: Touching Next time
  Given I am on the "Update Contacts" screen
  When I touch "Next time" button
  Then

Scenario: Touching Yeah,duh
  Given I am on the "Update Contacts" screen
  When I touch "Yeah,duh" button
  Then I should see a message: ""MugChat" wants to access your contact list. Do you allow it?"
  And I should see buttons: "Don't Allow" and "Allow"

#Ver com o Ben
Scenario: Touching don't allow option
  Given I am on the "Allow" message
  When I touch "Don't Allow" option
  Then I should see???

Scenario: Touching allow option
  Given I am on the "Allow" message
  When I touch "Allow" option
  Then I should see

#Aguardar resposta do Ben
Scenario: User loged in by facebook
Exibe mensagem de permissao tbm?
Atualiza com os contatos do face e do celular certo?
