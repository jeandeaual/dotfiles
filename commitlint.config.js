module.exports = {
    extends: ['@commitlint/config-conventional'],
    rules: {
        'type-enum': [
            2,
            'always',
            ['build', 'feature', 'fix', 'docs', 'style', 'refactor', 'revert', 'lint', 'spec']
        ],
        'header-max-length': [2, 'always', 255]
    }
};
