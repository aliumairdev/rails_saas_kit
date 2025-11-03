# frozen_string_literal: true

# Pagy initializer file (6.5.0)
# Customize only what you really need

# Default variables
Pagy::DEFAULT[:items] = 20
Pagy::DEFAULT[:size] = [1, 4, 4, 1]

# Better performance with the nav helper
require 'pagy/extras/overflow'
Pagy::DEFAULT[:overflow] = :last_page
