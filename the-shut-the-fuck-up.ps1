# YTP+++ PowerShell plugin: The Shut The Fuck Up
# PowerShell-native metadata prevents plugin discovery from parsing Lua syntax.

function Query {
    param($localeName, $localizationTokens)

    return @{
        name = 'The Shut The Fuck Up'
        description = 'YTP-style NVG pixel effect with safe default parameters.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'The Shut The Fuck Up'
                type = 'label'
            },
            @{
                name = 'Description'
                value = 'YTP-style NVG pixel effect with safe default parameters.'
                type = 'label'
            },
            @{
                name = 'amount'
                value = 5
                type = 'number'
            },
            @{
                name = 'seed_offset'
                value = 0
                type = 'number'
            }
        )
    }
}

function run {
    param($state)

    if ($null -eq $state) {
        return $null
    }

    return @($state.r, $state.g, $state.b)
}
