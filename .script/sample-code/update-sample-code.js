require('dotenv').config()

const fs = require('fs')
const util = require('util')
const path = require('path');
const exec = util.promisify(require('child_process').exec)

const tempPath = path.join(__dirname, '/_temporary')

async function updateSampleCode() {

    console.log('validating env...')
    validateENV()

    // Clean up and prepare temp folder.
    console.log('clean up ./_temporary')
    await exec(`rm -rf ${tempPath}`)
    await exec(`mkdir -p ${tempPath}`)

    console.log('scanning sample code chunks...')
    const chunks = await scanCode();

    console.log('extracting meta and raw_code...')
    let sampleCodes = []
    for(const chunk of chunks) {
        const obj = {
            'meta': extractMeta(chunk),
            'code': extractCode(chunk)
        }
        sampleCodes.push(obj)
    }

    console.log('updating sample codes...')
    // Execute `pushSampleCodeUpdate` tasks in parallel
    let tasks = []
    for (const sampleCode of sampleCodes) {
        const task = pushSampleCodeUpdate(sampleCode)
        tasks.push(task)
    }

    let changedMeta = []
    await Promise.all(tasks).then((values) => {
        for (const value of values) {
            if (value !== undefined) {
                changedMeta.push(value.meta)
            }
        }
    })

    // If you see this message, the tasks are done,
    console.log("All good 🚀!!")

    return changedMeta
}

async function scanCode() {
    const { stdout, stderr } = await exec('sh code_scanner.sh')
    if (stderr) {
        throw `scanCode stderr ${stderr}`
    }
    // Trim stdout, becasuse stdout always contain extra '\n' at the tail.
    let chunks = stdout.trim().split('----sample_code_separator----')
    // Remove last element, since it is always just white spaces.
    chunks.pop()
    // Trim each chunk again to git rid of white space at head and tail.
    chunks = chunks.map(chunk => {
        return chunk.trim()
    })
    return chunks
}

function extractMeta(chunk) {

    // Explanation: https://regex101.com/r/RP3BCU/1
    const regex = /.*begin_sample_code(.|\n)*?\*\/\n/;
    const m = chunk.match(regex)
    const header = m[0]

    let obj = {}

    const expectedKeys = ['gist_id', 'filename', 'asc_page', 'description']
    const keySet = new Set(expectedKeys)
    for (line of header.split('\n')) {
        // The line could be 'meta_url: https://www.google.com'
        // components = ['meta_url', 'https', '//www.google.com']
        const components = line.split(':')
        // The key is located at the head.
        const key = components[0].trim()
        // Drop the head, and join the rest back with ':', so we get the value.
        const value = components.slice(1).join(':').trim()
        if (keySet.has(key)) {
            obj[key] = value
        }
    }

    // Validate that the code chunk should contain all meta keys.
    for (const key of expectedKeys) {
        if (!obj.hasOwnProperty(key)) {
            console.error(`Unable to find meta.${key} in the code chunk:\n${chunk}`)
            throw `Unable to find meta.${key} in the code chunk`
        }
    }

    return obj

}

// Extract the raw code from code chunk.
function extractCode(chunk) {

    // ---------------------
        /* begin_sample_code
            key_1: ...
            key_2: ...
        */
    // ----------------------
    //  code_line_1
    //  code_line_2
    //  code_line_3
    // ----------------------
        /* end_sample_code */
    // ----------------------

    // Explanation: https://regex101.com/r/ThcfYZ/1
    const regex = /.*begin_sample_code(.|\n)*?\*\/\n((.|\n)*)\n(.*end_sample_code.*)/
    const m = chunk.match(regex)
    const code = m[2]
    const formattedCode = _formatCode(code)
    return formattedCode
}

function _formatCode(code) {
    // Removing some white spaces in front of lines.
    // 1. Find min white space prefix
    let minWhiteSpacePrefix = Number.MAX_SAFE_INTEGER
    for (const line of code.split('\n')) {
        // Only count for the line that is not empty, or just contains white spaces.
        if (line.trim() !== '') {
            const whiteSpacePrefix = line.search(/\S/)
            minWhiteSpacePrefix = Math.min(whiteSpacePrefix, minWhiteSpacePrefix)
        }
    }
    // 2. Remove first `minWhiteSpacePrefix` white space from each line.
    const regexWhiteSpace = new RegExp(`^ {${minWhiteSpacePrefix}}`, "gm");
    const beautifiedCode = code.replace(regexWhiteSpace, '')
    return beautifiedCode
}

async function pushSampleCodeUpdate(sampleCode) {

    const gist_id = sampleCode.meta.gist_id

    // All gist must belongs to one github user.
    const git_url = `https://${process.env.GH_USERNAME}:${process.env.GH_PERSONAL_ACCESS_TOKEN}@gist.github.com/${gist_id}.git`

    const localRepoPath = path.join(tempPath, gist_id)
    const codeFilePath = path.join(tempPath, gist_id, sampleCode.meta.filename)
    const placeholderFilePath = path.join(tempPath, gist_id, 'placeholder_file.txt')

    // Clone the latest git repo of the gist.
    await exec(`git clone ${git_url}`, { cwd: tempPath })

    // Delete the placeholder file from `create_gist.js` script.
    if (fs.existsSync(placeholderFilePath)) {
        fs.unlinkSync(placeholderFilePath)
    }

    // Update a code file in this git repo.
    if (fs.existsSync(codeFilePath)) {
        fs.unlinkSync(codeFilePath)
    }
    fs.writeFileSync(codeFilePath, sampleCode.code)

    const { stdout } = await exec(`git status --porcelain`, { cwd: localRepoPath })

    if (stdout.trim() === "") {
        // No change to commit
        console.log(`gist: ${gist_id} has no change to commit.`)
        return
    }

    console.log(`gist: ${gist_id} commit and push the changes.`)

    await exec([
        `git add .`,
        `git commit -m "Update sample code"`,
        `git push`
    ].join('\n'), {
        cwd: localRepoPath
    })

    return sampleCode
}

function validateENV() {

    const expectedKeys = [
        // The github user who owns all sample code gists.
        'GH_USERNAME',
        // The personal access token of that user; used for authenticate.
        'GH_PERSONAL_ACCESS_TOKEN'
    ]

    for (const key of expectedKeys) {
        if (!process.env.hasOwnProperty(key)) {
            console.error(`unable to find env.${key}.
- If you run this script on your local machine, plase make sure to create '.env' file from '.env_template'
- If you run this script on CI/CD, please make sure to inject env variables properly.
- The value of each key; can be asked from the admin of dynamic sample code feature.
`)
            throw `env does not contain ${key}`
        }
    }
}

if (require.main === module){
    updateSampleCode()
} else {
    module.exports = { updateSampleCode }
}