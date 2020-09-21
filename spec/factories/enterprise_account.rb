# frozen_string_literal: true

FactoryBot.define do
  factory :enterprise_account, class: Osso::Models::EnterpriseAccount do
    id { SecureRandom.uuid }
    name { Faker::Company.name }
    domain { Faker::Internet.domain_name }
    oauth_client
  end

  factory :enterprise_with_okta, parent: :enterprise_account do
    after :create do |enterprise|
      create(
        :configured_identity_provider,
        service: 'OKTA',
        domain: enterprise.domain,
        enterprise_account_id: enterprise.id,
      )
    end
  end

  factory :enterprise_with_azure, parent: :enterprise_account do
    after :create do |enterprise|
      create(
        :configured_identity_provider,
        service: 'AZURE',
        domain: enterprise.domain,
        enterprise_account_id: enterprise.id,
      )
    end
  end

  factory :enterprise_with_multiple_providers, parent: :enterprise_account do
    after :create do |enterprise|
      create(
        :configured_identity_provider,
        service: 'OKTA',
        domain: enterprise.domain,
        enterprise_account_id: enterprise.id,
      )

      create(
        :configured_identity_provider,
        service: 'AZURE',
        domain: enterprise.domain,
        enterprise_account_id: enterprise.id,
      )
    end
  end
end
