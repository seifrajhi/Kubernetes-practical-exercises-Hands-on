## Contributing to this Project

- [Contributing to OpenSearch](https://github.com/opensearch-project/.github/blob/main/CONTRIBUTING.md#contributing-to-opensearch)
  - [First Things First](https://github.com/opensearch-project/.github/blob/main/CONTRIBUTING.md#contributing-to-opensearch)
  - [Ways to Contribute](https://github.com/opensearch-project/.github/blob/main/CONTRIBUTING.md#ways-to-contribute)
    - [Bug Reports](https://github.com/opensearch-project/.github/blob/main/CONTRIBUTING.md#bug-reports)
    - [Feature Requests](https://github.com/opensearch-project/.github/blob/main/CONTRIBUTING.md#feature-requests)
    - [Documentation Changes](https://github.com/opensearch-project/.github/blob/main/CONTRIBUTING.md#documentation-changes)
    - [Contributing Code](https://github.com/opensearch-project/.github/blob/main/CONTRIBUTING.md#contributing-code)
  - [Developer Certificate of Origin](https://github.com/opensearch-project/.github/blob/main/CONTRIBUTING.md#developer-certificate-of-origin)
  - [Submitting a pull request](#submitting-a-pull-request)
  - [Review Process](https://github.com/opensearch-project/.github/blob/main/CONTRIBUTING.md#review-process)

  ## Submitting a Pull Request

  Before submitting a pull request make sure you have validated the following:
  1. Check the [Version and Branching](https://github.com/opensearch-project/helm-charts/blob/main/README.md#version-and-branching) section before commiting a change through PR.
  1. All the individual commits in the PR should be signed off. See DCO [section](https://github.com/opensearch-project/.github/blob/main/CONTRIBUTING.md#developer-certificate-of-origin) for more details. 
  1. Chart version should be bumped for every code change except docoumentation change. Refer the PR [#179](https://github.com/opensearch-project/helm-charts/pull/179) for an example.
  1. Make sure the PR does not have any merge conflicts. If there are any conflicts please rebase your commits over the code in `main` branch. 
  1. Ensure the linting and testing checks passes once you raise the PR. Unless the lint is passing the PR cannot be merged. You will be able to see the results of the workflows. In case it is failing you can use it to debug further.
