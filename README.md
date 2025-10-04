#### Industrial_Hydraulics_Project

## 0. Steps to follow to getting start
* Install git using the website [Git](https://git-scm.com/), you can also follow a video on YouTube if it helps you to install it but it is not very complicated,
* Create an account on [GitHub](https://github.com/)
* Create a folder called **Project** on your hard disk where you want to work (for me it is located here : \ENSE3\3A\COURSES\INDUSTRIAL HYDRAULICS\PROJECT\Project)
* Open the folder and DO NOT put things in, let it empty

## 1. Configure Git and Your Account
* Do a right click and select **Open Git Bash here**, if you don't see it you may click on **display other options** after the right click
* In the terminal write :
** git config --global user.name "Your Name"
** git config --global user.email "your.email@example.com"
## 2. Generate a Personal Access Token (PAT) on GitHub:
* Go to: Settings > Developer settings > Personal access tokens > Tokens(classic)
* Click on Generate new token (classic) and select a duration of 90 days
* Copy your token and **copy** it bur **DO NOT** share it
* Use the token instead of your GitHub password when Git asks for authentication
## 3. Connect Local Repository to GitHub
* Initialize a new repo by opening a Git Bash terminal in the **project** folder and writting : git init
* Link your local repo to the remote GitHub repository. In the same terminal write : git remote add origin https://github.com/noerajon/Industrial_Hydraulics_Project.git
* To check the connection : git remote -v
