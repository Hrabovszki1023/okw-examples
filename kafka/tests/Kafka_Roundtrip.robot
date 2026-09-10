*** Settings ***
Documentation     Stage 3 Integrationstest: Kafka Produce, Consume, Verify gegen echten Broker.
...               Broker wird per OKW-Docker-Keywords provisioniert (KRaft-Mode).
Library           okw_env_docker.library.OkwEnvDockerLibrary
...               components_dir=${CURDIR}${/}..${/}components
Library           okw_kafka.library.OkwKafkaLibrary
...               config_dir=${CURDIR}${/}..${/}configs    backend=confluent
Suite Setup       Starte Kafka Broker
Suite Teardown    Run Keywords    Beende Kafka    ENV_Stop

*** Keywords ***
Starte Kafka Broker
    ENV_Start          KafkaTestBroker
    ENV_BuildAndRun
    ENV_WaitForReady   KafkaTestBroker
    KafkaStart         kafka-local

Beende Kafka
    KafkaStop

*** Test Cases ***
Produce und Consume Roundtrip
    [Documentation]    Nachricht senden und empfangen.
    KafkaSetTopic       okw-test-roundtrip
    KafkaSetValue       $.action    create
    KafkaSetValue       $.item      Widget-42
    KafkaSetKey         order-001
    KafkaSetHeader      correlation-id    test-001
    KafkaProduce

    KafkaConsume        okw-test-roundtrip    TIMEOUT=30
    KafkaVerifyValue    $.action    create
    KafkaVerifyValue    $.item      Widget-42
    KafkaVerifyKey      order-001
    KafkaVerifyHeader   correlation-id    test-001

Produce und Consume mit Filter
    [Documentation]    Zwei Nachrichten senden, per Filter die richtige konsumieren.
    KafkaSetTopic       okw-test-filter
    KafkaSetValue       $.item      A
    KafkaProduce

    KafkaSetValue       $.item      B
    KafkaProduce

    KafkaConsume        okw-test-filter    FILTER=$.item=B    TIMEOUT=30
    KafkaVerifyValue    $.item      B

Verify mit Wildcard und Regex
    [Documentation]    Match-Modes WCM und REGX gegen echte Kafka-Nachrichten.
    KafkaSetTopic       okw-test-matchmodes
    KafkaSetValue       $.message    Order created successfully
    KafkaSetValue       $.code       12345
    KafkaProduce

    KafkaConsume             okw-test-matchmodes    TIMEOUT=30
    KafkaVerifyValueWCM      $.message    *successfully
    KafkaVerifyValueREGX     $.code       \\d{5}

Topic Existenz Pruefen
    [Documentation]    Admin-Keyword: prueft ob ein Topic existiert.
    KafkaSetTopic       okw-test-admin
    KafkaSetValue       $.x         1
    KafkaProduce

    KafkaVerifyTopicExists    okw-test-admin    YES
    KafkaVerifyTopicExists    nonexistent-topic-xyz    NO
