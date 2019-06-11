FROM matkt/solc-image
RUN mkdir ./aiakos-contracts
COPY . /aiakos-contracts/
WORKDIR /aiakos-contracts/
RUN npm install
RUN SOLC_ARGS='openzeppelin-solidity=./node_modules/openzeppelin-solidity' soldoc . contracts doc -o doc/docs
RUN cd doc/website && npm install && npm run build && - cp -rf build/Aiakos/* ../../public/
