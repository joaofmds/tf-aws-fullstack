<template>
  <div class="container">

    <div class="row">
      <div class="card">
        <div class="card-header">
          <strong>Importação de produtos</strong>
        </div>
        <div class="card-body">
          <p>
            Selecione um arquivo CSV para realizar a importação.
            <br />
            <strong>Formato CSV</strong>: name,cost_price,sale_price,quantity
          </p>
          <div class="input-group">
            <input type="file" class="form-control" aria-describedby="input_produtos" id="input_produtos" ref="file"
              @change="selectFile" aria-label="Upload" accept=".csv" />
            <button class="btn btn-primary" :disabled="file == null" type="button" @click="uploadFile">Importar</button>
          </div>
          <br>
          <div v-if="error_message" class="alert alert-danger" role="alert">
            {{ error_message }}
          </div>
          <div v-if="success_message" class="alert alert-success" role="alert">
            {{ success_message }}
          </div>
        </div>
      </div>
    </div>

    <div class="row mt-4">
      <div class="card">
        <div class="card-header">
          <strong>Importações realizadas</strong>
        </div>
        <div class="card-body">
          <table class="table table-striped table-hover">
            <thead>
              <tr>
                <th scope="col">Data 2</th>
                <th scope="col">Nome</th>
                <th scope="col">Preço Custo</th>
                <th scope="col">Preço Venda</th>
                <th scope="col">Qtd Estoque</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="product in products" :key="product.id">
                <td>{{ formatDate(product.created_at) }}</td>
                <td>{{ product.name }}</td>
                <td>{{ product.cost_price }}</td>
                <td>{{ product.sale_price }}</td>
                <td>{{ product.quantity }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

  </div>
</template>

<script>

import axios from 'axios';
import moment from 'moment';
const API_URL = process.env.VUE_APP_API_URL || 'http://localhost:8081/api/';
console.log('API_URL:', API_URL);

export default {
  name: 'ProductIndex',
  props: {
    msg: String
  },
  data() {
    return {
      file: null,
      products: [],
      error_message: null,
      success_message: null,
    }
  },
  mounted() {
    this.loadProducts();
  },
  methods: {
    formatDate(date) {
      return moment(date).format("DD/MM/YYYY HH:mm:ss");
    },
    selectFile() {
      this.file = this.$refs.file.files[0];
    },
    async uploadFile() {
      this.error_message = null;
      this.success_message = null;

      const formData = new FormData();
      formData.append('file', this.file);

      const headers = { 'Content-Type': 'multipart/form-data' };

      let vm = this;

      await axios.post(API_URL + 'import_file', formData, { headers })
        .then((response) => {
          vm.success_message = response.data.detail;
          vm.file = null;
          document.getElementById('input_produtos').value = null;
          vm.loadProducts();
        })
        .catch(function (error) {
          if (error.response.data.detail) {
            vm.error_message = error.response.data.detail;
          } else {
            vm.error_message = error.response.statusText;
          }
        });
    },
    async loadProducts() {
      await axios.get(API_URL + 'products')
        .then((response) => {
          this.products = response.data;
        })
        .catch(function (error) {
          console.log(error);
        });
    }
  }
}
</script>


<style scoped>
</style>
