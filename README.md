```
      ___           ___           ___           ___           ___           ___     
     /\  \         /\  \         /\  \         /\__\         /\  \         /\__\    
    /::\  \        \:\  \       /::\  \       /::|  |       /::\  \       /::|  |   
   /:/\:\  \        \:\  \     /:/\:\  \     /:|:|  |      /:/\:\  \     /:|:|  |   
  /::\~\:\  \       /::\  \   /:/  \:\  \   /:/|:|__|__   /::\~\:\  \   /:/|:|  |__ 
 /:/\:\ \:\__\     /:/\:\__\ /:/__/ \:\__\ /:/ |::::\__\ /:/\:\ \:\__\ /:/ |:| /\__\
 \:\~\:\ \/__/    /:/  \/__/ \:\  \  \/__/ \/__/~~/:/  / \/__\:\/:/  / \/__|:|/:/  /
  \:\ \:\__\     /:/  /       \:\  \             /:/  /       \::/  /      |:/:/  / 
   \:\ \/__/     \/__/         \:\  \           /:/  /        /:/  /       |::/  /  
    \:\__\                      \:\__\         /:/  /        /:/  /        /:/  /   
     \/__/                       \/__/         \/__/         \/__/         \/__/    
```

Config management for people who think /etc should stay in /etc, not in a YAML fever dream.

## Why etcman? (aka "The Rant")

Are you tired of writing 50-line playbooks just to change one setting on your own server? Do you shiver, just a little bit, when someone mentions "infrastructure as code"? If you've ever thought, "I just want to edit my damn files" while drowning in a sea of YAML, etcman is your life raft.

etcman is for the 'get off my lawn' sysadmin in all of us. It's for those who believe the best configuration language is the one you already know: your config files.

## What etcman Does (Without the Buzzwords)

- Lets you edit files in /etc like a normal person
- Tracks what you've changed without needing a PhD in Git (a BSc is fine)
- Remembers what packages you've installed (the ones you actually meant to install)
- Backs up your stuff without needing a separate degree in cloud engineering

## Who Needs This?

- Sysadmins who think `vim` and `git` are perfectly good configuration management tools
- Anyone who's ever said, "It's just a config file!" and meant it
- People who believe simplicity is the ultimate sophistication in system management
- Those who want their system configs backed up, not obfuscated in five layers of abstraction

If you've ever felt like you're shouting at clouds when dealing with modern config management tools, welcome home.

## The Good Stuff (Features, I guess)

- Git-based version control for /etc (but only the files you actually touched)
- One repository for one server (let's be honest, we all have pets)
- Tracks only the packages you meant to install (not the 500 dependencies you didn't know about)
- Debug logging (for when things inevitably go wrong)
- APT hook integration (fancy words for "it works with your package manager")

## Getting Started (It's Not Rocket Science)

1. Grab etcman:
   ```
   git clone https://github.com/mikn/etcman.git
   ```

2. Set it up:
   ```
   cd etcman
   sudo make install
   ```
3. Connecting to a remote repository (Because Your Configs Deserve the Cloud)
  (First you create the remote repository, with a suggestive name like `etcman-servername`)
  ```
  sudo etcman remote add origin git@github.com:your-user-name/etcman-servername.git
  ```

4. Use it (yes, it's that simple):
   ```
   sudo etcman status
   sudo etcman add /etc/some_config_file
   sudo etcman commit -m "Updated some_config_file because I felt like it"
   ```

5. See what packages you've doomed your system with:
   ```
   cat /etc/etcman/package-list.conf
   ```

6. Back it up (because accidents happen):
   ```
   sudo etcman push origin main
   ```

## etcman and etckeeper: Two Peas in a /etc Pod

You might be wondering, "How does etcman compare to the venerable etckeeper?" Great question! Let's take a friendly look at these two tools that both aim to make our lives as sysadmins a bit easier.

### Common Ground (Because Great Minds Think Alike)

- Both track changes in /etc (the heart of your system's soul)
- Both leverage the power of Git (because, let's be fair, git won)
- Both can integrate with package managers (teamwork makes the dream work)

### Where etckeeper Shines

1. **Comprehensive Tracking**: 
   etckeeper diligently tracks every change in /etc. If you want a complete historical record, etckeeper has your back.

2. **Broad VCS Support**: 
   While etcman is Git-focused, etckeeper supports multiple version control systems. Options are always nice!

3. **Works with most Package Managers**: 
   etcman only works with APT, etckeeper works with most linux distro package managers! Wooh!

4. **Automatic Commits**: 
   etckeeper can automatically commit changes made by package managers. It's like having a very attentive secretary for your /etc.

### Where etcman Struts Its Stuff

1. **Focused Package Tracking**: 
   etcman specifically tracks manually installed packages. It's like having a diary of your intentional system changes.

2. **Simplified Configuration**:
   With a straightforward Makefile, etcman aims for simplicity in setup and use. Sometimes, less is more!

3. **Emphasis on Manual Changes**:
   etcman focuses on the changes you make deliberately, helping to separate the signal from the noise.

4. **Backup Philosophy**:
   etcman keeps your /etc as-is and maintains a separate record of important changes. It's like having a knowledgeable guide for your system's journey.

### Choosing Your /etc Companion

- If you want a detailed, automated history of everything that happens in /etc, etckeeper might be your new best friend.
- If you prefer a more curated approach that focuses on your manual changes and installations, etcman could be your cup of tea.

The beauty is, there's room for both in the world of system management. etckeeper and etcman are like different flavors of ice cream - both delicious, but catering to different tastes.

Remember, the best tool is the one that fits your workflow and makes your life easier. Whether that's etckeeper, etcman, or a charming combination of both (just don't tell me how you achieved that monstrosity), the important thing is that you're taking steps to manage your system thoughtfully.

After all, in the grand tapestry of system administration, we're all just trying to keep our /etc directories happy and healthy!

## The Fine Print (License)

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details. But let's be honest, you weren't going to read that anyway.

Remember, with great power comes great responsibility. Or in this case, with simple tools come fewer headaches. Happy configuring!
