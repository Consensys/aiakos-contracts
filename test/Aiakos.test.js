// Import all required modules from openzeppelin-test-helpers
const { BN, constants, expectEvent, expectRevert } = require('openzeppelin-test-helpers');
// Import preferred chai flavor: both expect and should are supported
const { expect } = require('chai');
const BigNumber = web3.BigNumber;

const AiakosMock = artifacts.require('Aiakos');

require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(BigNumber))
.should();

contract('Aiakos', function (accounts) {
  const requiredNumberOfMaintainers = 2;
  const releaseVersion = "1.0.0";
  const releaseHash = "0x6412de0cd1e0c7c92664a6c11629949a935eccc1c11e639d8c9c84e15cafff3a";
  const nonGenuineHash = "0x0666ed9a1cdca4a743b852ac7f482912683089984c423ee8770e80d64e859918";
  const [
    owner,
    maintainer1,
    maintainer2,
    anyone
  ] = accounts;

  beforeEach(async function () {
    this.aiakos = await AiakosMock.new(requiredNumberOfMaintainers, { from: owner });
  });


 it('emits MaintainerAdded event when adding maintainer', async function () {
   const { logs } = await this.aiakos.addMaintainer(maintainer1, { from: owner });
   expectEvent.inLogs(logs, 'MaintainerAdded', { maintainer: maintainer1 });
   const isMaintainer = await this.aiakos.amIMaintainer({ from: maintainer1 });
   isMaintainer.should.equal(true);
 });

 it('returns false when owner verifies if he is a maintainer', async function () {
   const ownerIsMaintainer = await this.aiakos.amIMaintainer({ from: owner });
   ownerIsMaintainer.should.equal(false);
 });

 it('reverts when maintainer is trying to add maintainer', async function () {
   await this.aiakos.addMaintainer(maintainer1, { from: owner });
   await expectRevert(
      this.aiakos.addMaintainer(maintainer2, { from: maintainer1 }), 'Ownable: caller is not the owner'
    );
 });

 it('reverts when anyone is trying to add maintainer', async function () {
   await expectRevert(
      this.aiakos.addMaintainer(maintainer2, { from: anyone }), 'Ownable: caller is not the owner'
    );
 });

 it('reverts when non maintainer user is trying to deploy a release', async function () {
   await expectRevert(
      this.aiakos.deployRelease(releaseVersion, releaseHash, { from: anyone }), 'Aiakos: caller is not a maintainer.'
    );
 });

 it('ensures that maintainer can grant approval for a release', async function () {
   await this.aiakos.addMaintainer(maintainer1, { from: owner });
   const { logs } = await this.aiakos.deployRelease(releaseVersion, releaseHash, { from: maintainer1 });
   expectEvent.inLogs(logs, 'ApprovalGranted', {maintainer: maintainer1, version: releaseVersion});
 });

 it('ensures that a release is approved when required number of approvals has been granted', async function () {
   // owner adds the first maintainer
   await this.aiakos.addMaintainer(maintainer1, { from: owner });
   // owner adds the second maintainer
   await this.aiakos.addMaintainer(maintainer2, { from: owner });
   // first maintainer grants approval
   await this.aiakos.deployRelease(releaseVersion, releaseHash, { from: maintainer1 });
   // second maintainer grants approval, release must be approved
   const { logs } = await this.aiakos.deployRelease(releaseVersion, releaseHash, { from: maintainer2 });
   expectEvent.inLogs(logs, 'ReleaseApproved', {version: releaseVersion});
   const releaseInfo = await this.aiakos.getReleaseInfo(releaseVersion, {from: anyone});
   releaseInfo['0'].should.equal(releaseVersion);
   releaseInfo['1'].should.equal(releaseHash);
   releaseInfo['2'].should.equal(true);
   releaseInfo['3'].should.equal(true);
   const isReleaseOk = await this.aiakos.checkRelease(releaseVersion, releaseHash, {from: anyone});
   isReleaseOk.should.equal(true);
   await expectRevert(
      this.aiakos.checkRelease(releaseVersion, nonGenuineHash, {from: anyone}), 'Aiakos.Releases.check: Mistmatch release hashes.'
   );
 });




});
