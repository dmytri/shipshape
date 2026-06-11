# Gherkin feature file template for Shipshape
# This is the canonical spec format. Captain writes these files.
# Quartermaster turns them into step definitions and tests.
#
Feature: <feature name>
  As a <user or system>
  I want <capability>
  So that <outcome>

  Background:
    Given <shared precondition>

  Rule: <normative rule name>
    <Short explanation of the rule. Avoid implementation details unless they are part of the contract.>

    Scenario: <expected behavior>
      Given <initial state>
      And the approved asset "assets/<path-to-asset>" if this behavior depends on Captain/human-authored content, media, design, data, or fixture-like examples
      When <action>
      Then <observable result>

    Scenario: <edge case or failure behavior>
      Given <initial state>
      When <action>
      Then <observable result>

  # Optional non-normative section:
  # Open questions:
  # - <question not yet decided>
