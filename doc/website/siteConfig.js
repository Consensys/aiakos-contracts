/**
 * Copyright (c) 2017-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
const siteConfig = {
  title: 'Aiakos documentation' /* title for your website */,
  tagline: 'Aiakos: Release on the blockchain',
  url: 'https://github.com/PegaSysEng/aiakos-contracts' /* your website url */,
  baseUrl: '/aiakos/' /* base url for your project */,

  // Used for publishing and more
  projectName: 'Aiakos',
  organizationName: 'Pegasys',
  // For no header links in the top nav bar -> headerLinks: [],
  headerLinks: [
    {doc: 'Aiakos', label: 'Aiakos'},
    {doc: 'Releases', label: 'Releases'}
  ],

  /* path to images for header/footer */
  headerIcon: 'img/docusaurus.svg',
  favicon: 'img/favicon.png',

  /* colors for website */
  colors: {
    primaryColor: '#1D2041',
    secondaryColor: '#3f468d',
  },

  /* custom fonts for website */
  /*fonts: {
    myFont: [
      "Times New Roman",
      "Serif"
    ],
    myOtherFont: [
      "-apple-system",
      "system-ui"
    ]
  },*/

  // This copyright info is used in /core/Footer.js and blog rss/atom feeds.
  copyright:
    'Copyright © ' +
    new Date().getFullYear() +
    ' Consensys',

  highlight: {
    // Highlight.js theme to use for syntax highlighting in code blocks
    theme: 'default',
  },

  // Add custom scripts here that would be placed in <script> tags
  scripts: ['https://buttons.github.io/buttons.js'],

  /* On page navigation for the current documentation page */
  onPageNav: 'separate',



};

module.exports = siteConfig;
