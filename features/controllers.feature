Feature: `controllers` folder autoloading
  In order to make controllers development easier
  As a Piano developer
  I want to have Piano automatically loading them

Scenario: Test one file
  Given I have a "hello.controller" file in the controllers folder
  And its get "/" outputs "Hello!"
  When I run the piano server on port "4567"
  And I get to "http://localhost:4567/"
  Then I should see "Hello!"

Scenario: Files ending in other than .controller are not loaded
  Given I have a "hello.not_a_c" file in the controllers folder
  And its get "/" outputs "Not for your eyes!"
  When I run the piano server on port "4567"
  And I get to "http://localhost:4567"
  Then I should not see "Not for your eyes!"
