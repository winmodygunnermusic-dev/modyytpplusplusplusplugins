# YTP+++ PowerShell plugin: Hateful Effect This Effect Takes
# PowerShell-native metadata prevents plugin discovery from parsing Lua syntax.

function Query {
    param($localeName, $localizationTokens)

    return @{
        name = 'Hateful Effect This Effect Takes'
        description = 'Hateful Effect This Effect Takes YTP+++ plugin.'
        settings = @(
            @{
                name = 'Display Name'
                value = '''Hateful Effect This Effect Takes'''
                type = 'label'
            },
            @{
                name = 'Description'
                value = '''Hateful Effect This Effect Takes YTP+++ plugin.'''
                type = 'label'
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
