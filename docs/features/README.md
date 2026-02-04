# Gherkin Feature Specifications

Dit directory bevat Gherkin feature specifications die het gedrag van deze Terraform module definiëren volgens Behavior-Driven Development (BDD) principes.

## Wat zijn Gherkin Features?

Gherkin features zijn geschreven in een begrijpelijke taal (Given-When-Then formaat) die:
- Het gewenste gedrag van de module beschrijven
- Als basis dienen voor geautomatiseerde tests
- Levende documentatie vormen van de module capabilities
- Communicatie faciliteren tussen developers en stakeholders

## Formaat

Feature files volgen de Gherkin syntax:
- **Feature**: Beschrijving van de module capability
- **Background**: Gemeenschappelijke setup voor alle scenarios
- **Scenario**: Specifieke use case met Given-When-Then stappen
- **Scenario Outline**: Template voor meerdere variaties met Examples

## Naamgeving

Feature bestanden gebruiken kebab-case:
- Formaat: `feature-name.feature`
- Beschrijvende naam die de capability beschrijft
- Voorbeelden:
  - `ecs-fargate-service.feature`
  - `auto-scaling-configuration.feature`
  - `service-connect-integration.feature`

## Overzicht

<!-- Hier komen links naar alle features -->

_Nog geen features in deze module._

## Test-Driven Development Workflow

1. **Scenario Shaping**: Features worden geschreven vanuit requirements (door `scenario-shaper` agent)
2. **Test Creation**: Features worden vertaald naar Terraform tests (door `terraform-tester` agent)
3. **Implementation**: Code wordt geschreven om tests te laten slagen (door `terraform-module-specialist` agent)
4. **Documentation**: Module wordt gedocumenteerd (door `documentation-specialist` agent)
5. **Examples**: Runnable examples worden gemaakt (door `examples-specialist` agent)

## Template

Voor nieuwe features, zie de Gherkin syntax voorbeelden in de agent documentatie.

## Meer Informatie

- [Gherkin Reference](https://cucumber.io/docs/gherkin/reference/)
- [Behavior-Driven Development](https://cucumber.io/docs/bdd/)
- [Terraform Testing](https://developer.hashicorp.com/terraform/language/tests)
