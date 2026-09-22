# YTP+++ PowerShell plugin: Spadinnertwo
# PowerShell-native metadata prevents plugin discovery from parsing Lua syntax.

function Query {
    param($localeName, $localizationTokens)

    return @{
        name = 'Spadinnertwo'
        description = 'Spadinnertwo YTP+++ plugin.'
        settings = @(
            @{
                name = 'Display Name'
                value = '''Spadinnertwo'''
                type = 'label'
            },
            @{
                name = 'Description'
                value = '''Spadinnertwo YTP+++ plugin.'''
                type = 'label'
            }
        )
    }
}
